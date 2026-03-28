"""
Repair script for Architect questions with bloated option lists.

Re-parses specific broken questions from the original Udemy markdown source files
using an improved parser that correctly handles:
- Multi-line options with SQL code blocks
- Scenario context between question text and options
- Options that span description + code lines

Usage: python Scripts/repair_architect_questions.py
"""

import json
import os
import re
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
QUESTIONS_FILE = os.path.join(
    BASE,
    "certifications",
    "sfc-gh-sd-advanced",
    "architect_domains",
    "architect_questions.json",
)
SOURCE_DIR = os.path.join(
    BASE,
    "certifications",
    "sfc-gh-sd-advanced",
    "Snowprocore_architect",
    "course_arquitec t_udemy",
)
SOURCE_FILES = {
    "test1": "course_01_architect_test example_1.md",
    "test2": "course_01_architect_test example_2.md",
    "test3": "course_01_architect_test example_3.md",
    "test4": "course_01_architect_test example_4.md",
    "test5": "course_01_architect_test example_5.md",
}

MARKER_MAP = {
    "Correct answer": "correct_single",
    "Correct selection": "correct_multi",
    "Your answer is incorrect": "wrong",
    "Your selection is incorrect": "wrong",
    "Your selection is correct": "correct_single",
    "Your answer is correct": "correct_single",
}

# Markers that indicate the start of a correct option
CORRECT_MARKERS = {"correct_single", "correct_multi"}


def split_into_questions(text):
    """Split markdown text into raw question blocks."""
    text = text.replace("\r\n", "\n")
    parts = re.split(r"\n(?:Q|q)?uestion\s+(\d+)\s*\n", text)

    blocks = {}
    # Handle preamble (Q1 without header -- BOM issue in test1)
    preamble = parts[0].strip()
    if preamble and "Overall explanation" in preamble:
        blocks[1] = preamble

    i = 1
    while i < len(parts) - 1:
        qnum = int(parts[i])
        body = parts[i + 1].strip()
        blocks[qnum] = body
        i += 2

    return blocks


def _find_question_boundary(qo_lines, first_marker_idx):
    """Find where the question text ends and options begin.

    The question boundary is the last line that's clearly part of the question,
    NOT part of the options zone. We search backwards from the first marker
    to find where actual answer options start.

    Heuristic: scan backwards from first_marker_idx. The first blank-line-separated
    block that looks like a short answer option (not a question/scenario) marks the
    start of the options zone. Everything before it is question text.
    """
    # Find the last question-like line (ends with ?)
    last_q_line = -1
    for i in range(first_marker_idx - 1, -1, -1):
        s = qo_lines[i].strip()
        if s.endswith("?"):
            last_q_line = i
            break

    if last_q_line >= 0:
        # Options zone starts after the question line (skip blank lines)
        boundary = last_q_line + 1
        while boundary < first_marker_idx and qo_lines[boundary].strip() == "":
            boundary += 1
        return boundary

    # Fallback: if no "?" found, use blank-line heuristic
    # Find the last substantial blank-line gap before the first marker
    # that separates scenario context from options
    for i in range(first_marker_idx - 1, 0, -1):
        if qo_lines[i].strip() == "" and qo_lines[i - 1].strip() != "":
            # Check if content after this blank line looks like options
            # (short lines, not numbered list items that are scenario)
            next_content = []
            for j in range(i + 1, first_marker_idx):
                s = qo_lines[j].strip()
                if s:
                    next_content.append(s)
            if next_content and all(len(s) < 200 for s in next_content):
                return i + 1

    return first_marker_idx


def improved_parse(raw_body):
    """Parse a question block with improved logic for handling context/SQL in options.

    Strategy:
    1. Remove status line (Skipped/Incorrect/Correct at start)
    2. Split at 'Overall explanation'
    3. Find ALL marker positions
    4. Find question boundary: ends at last "?" line (or heuristic)
    5. Between question boundary and markers: these are UNMARKED options
    6. Markers introduce MARKED options (correct or selected-wrong)
    7. All blank-line-separated blocks in the options zone are individual options
    """
    lines = raw_body.split("\n")

    # Remove first-line status
    STATUS_LINES = {"Skipped", "Incorrect", "Correct"}
    if lines and lines[0].strip() in STATUS_LINES:
        lines = lines[1:]
    text = "\n".join(lines)

    # Split at "Overall explanation"
    expl_match = re.split(r"\nOverall explanation\s*\n?", text, maxsplit=1)
    qo_part = expl_match[0].strip()
    explanation = expl_match[1].strip() if len(expl_match) > 1 else ""

    # Clean explanation
    explanation = re.sub(
        r"\s*For more detailed information,?\s*refer to the official Snowflake documentation\.?\s*$",
        "",
        explanation,
    ).strip()

    qo_lines = qo_part.split("\n")

    # Find all marker positions and their types
    markers = []  # [(line_idx, marker_type), ...]
    marker_set = set()
    for i, line in enumerate(qo_lines):
        s = line.strip()
        if s in MARKER_MAP:
            markers.append((i, MARKER_MAP[s]))
            marker_set.add(i)

    if not markers:
        return None

    first_marker_idx = markers[0][0]

    # Find question boundary
    q_boundary = _find_question_boundary(qo_lines, first_marker_idx)

    question_lines = qo_lines[:q_boundary]
    question_text = "\n".join(question_lines).strip()
    question_text = re.sub(r"\n{3,}", "\n\n", question_text)

    # Now collect ALL content blocks in the options zone
    # A "block" is consecutive non-empty lines separated by blank lines or markers
    options = []
    correct_indices = []
    is_multi = False

    # Walk through the options zone line by line
    current_marker = None  # marker type for the current block
    current_block_lines = []

    def flush_block():
        nonlocal current_marker
        block_text = "\n".join(current_block_lines).strip()
        if block_text:
            if current_marker in CORRECT_MARKERS:
                correct_indices.append(len(options))
                if current_marker == "correct_multi":
                    nonlocal is_multi
                    is_multi = True
            options.append(block_text)
        current_block_lines.clear()
        current_marker = None

    for li in range(q_boundary, len(qo_lines)):
        if li in marker_set:
            # Flush any accumulated block
            flush_block()
            # Set marker for next block
            current_marker = MARKER_MAP[qo_lines[li].strip()]
            continue

        s = qo_lines[li].strip()
        if s == "":
            # Blank line: might separate options
            if current_block_lines:
                flush_block()
            continue

        current_block_lines.append(qo_lines[li])

    # Flush last block
    flush_block()

    if not options or not question_text:
        return None

    # Detect multi-select from question text
    multi_match = re.search(
        r"\((?:Select|Choose)\s+(TWO|THREE|FOUR|two|three|four|2|3|4)\)",
        question_text,
        re.IGNORECASE,
    )
    if multi_match:
        is_multi = True
        count_map = {"two": 2, "three": 3, "four": 4, "2": 2, "3": 3, "4": 4}
        multi_count = count_map.get(multi_match.group(1).lower(), 2)
    else:
        multi_count = len(correct_indices) if is_multi else 1

    return {
        "question": question_text,
        "options": [{"text": o, "explanation": ""} for o in options],
        "correct_indices": correct_indices,
        "multi_select": is_multi or len(correct_indices) > 1,
        "multi_select_count": max(multi_count, len(correct_indices)),
        "overall_explanation": explanation,
    }


def main():
    # Load current questions
    with open(QUESTIONS_FILE, "r", encoding="utf-8") as f:
        questions = json.load(f)

    # Find all questions that need repair:
    # - >6 options (bloated from bad parsing)
    # - <3 options (over-merged from first repair attempt)
    broken_map = {}  # id -> index in questions list
    for idx, q in enumerate(questions):
        n_opts = len(q.get("options", []))
        if n_opts > 6 or n_opts < 3:
            broken_map[q["id"]] = idx

    print(f"Found {len(broken_map)} questions to repair")

    # Group by source test
    source_needs = {}
    for qid in broken_map:
        m = re.match(r"architect_(test\d+)_q(\d+)", qid)
        if m:
            source = m.group(1)
            qnum = int(m.group(2))
            source_needs.setdefault(source, {})[qnum] = qid

    # Process each source file
    fixed_count = 0
    still_broken = []

    for source, qnums_map in sorted(source_needs.items()):
        fname = SOURCE_FILES.get(source)
        if not fname:
            print(f"SKIP: No source file for {source}")
            continue

        fpath = os.path.join(SOURCE_DIR, fname)
        if not os.path.exists(fpath):
            print(f"SKIP: {fpath} not found")
            continue

        with open(fpath, "r", encoding="utf-8") as f:
            raw_text = f.read()

        blocks = split_into_questions(raw_text)

        for qnum, qid in sorted(qnums_map.items()):
            if qnum not in blocks:
                print(f"  WARN: {qid} (Q{qnum}) not found in {fname}")
                still_broken.append(qid)
                continue

            result = improved_parse(blocks[qnum])
            if not result:
                print(f"  WARN: {qid} failed to parse")
                still_broken.append(qid)
                continue

            n_opts = len(result["options"])
            n_correct = len(result["correct_indices"])

            # Get the original question entry
            orig_idx = broken_map[qid]
            orig = questions[orig_idx]
            orig_opts = len(orig["options"])

            # Only apply repair if it's actually better
            is_good = 3 <= n_opts <= 6 and n_correct >= 1
            is_better = n_opts < orig_opts and n_correct >= 1 and n_opts >= 3

            if is_good or is_better:
                # Update the question with repaired data
                questions[orig_idx]["question"] = result["question"]
                questions[orig_idx]["options"] = result["options"]
                questions[orig_idx]["correct_indices"] = result["correct_indices"]
                questions[orig_idx]["multi_select"] = result["multi_select"]
                questions[orig_idx]["multi_select_count"] = result["multi_select_count"]
                questions[orig_idx]["overall_explanation"] = result["overall_explanation"]

                status = "OK" if is_good else "IMPROVED"
                print(f"  {qid}: {orig_opts} -> {n_opts} opts, {n_correct} correct [{status}]")
                fixed_count += 1
            else:
                status = "KEPT_ORIGINAL"
                if n_opts < 3:
                    status = f"KEPT_ORIGINAL (repair={n_opts} opts, too few)"
                elif n_opts > 6:
                    status = f"KEPT_ORIGINAL (repair={n_opts} opts, still bloated)"
                print(f"  {qid}: {orig_opts} opts [{status}]")
                still_broken.append(qid)

    print(f"\nRepaired: {fixed_count}")
    print(f"Still problematic: {len(still_broken)}")
    if still_broken:
        for qid in still_broken:
            idx = broken_map.get(qid)
            if idx is not None:
                n = len(questions[idx]["options"])
                print(f"  {qid}: {n} options")

    # Write repaired file
    with open(QUESTIONS_FILE, "w", encoding="utf-8") as f:
        json.dump(questions, f, indent=2, ensure_ascii=False)

    print(f"\nWritten repaired questions to {QUESTIONS_FILE}")

    # Final stats
    opt_counts = {}
    for q in questions:
        n = len(q["options"])
        opt_counts[n] = opt_counts.get(n, 0) + 1
    print("\nOption count distribution after repair:")
    for n, c in sorted(opt_counts.items()):
        print(f"  {n} options: {c} questions")


if __name__ == "__main__":
    main()
