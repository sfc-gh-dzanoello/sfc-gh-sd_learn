"""
Generic Udemy-style markdown question parser for SnowPro certification exams.

Parses Udemy test export markdown files into the standard questions JSON format
used by the PS Platform study app.

Usage:
    python Scripts/parse_questions.py <cert_key> <output.json> <test1.md> [test2.md ...]

    cert_key   : Short name used as ID prefix (e.g., "genai", "de", "core")
    output.json: Path where the parsed questions JSON will be written
    test1.md   : One or more Udemy-exported markdown test files

Options:
    --domains <domains.json>  : Optional JSON file with domain keyword config
                                 for auto-classification (see below)
    --default-domain <name>   : Domain name to assign when no keywords match
                                 (default: "Untagged")

Domain config JSON format (--domains):
    {
      "Domain 1: Example Domain": {
        "weight": "30%",
        "keywords": ["keyword1", "keyword2", ...]
      },
      ...
    }

Examples:
    # Parse 3 Data Engineer test files:
    python Scripts/parse_questions.py de output/de_questions.json \\
        tests/de_test1.md tests/de_test2.md tests/de_test3.md

    # Parse with domain auto-classification:
    python Scripts/parse_questions.py genai output/genai_questions.json \\
        tests/genai_test1.md --domains config/genai_domains.json

    # Parse a single file with a default domain:
    python Scripts/parse_questions.py core output/core_questions.json \\
        tests/core_test1.md --default-domain "Domain 1: Core Concepts"
"""

import argparse
import json
import os
import re
import sys


# ── Parsing engine (from parse_de_questions.py, generalized) ──


def classify_domain(question_text, options_text, explanation_text, domains):
    """Assign a domain based on keyword frequency in the full question context."""
    if not domains:
        return None
    full_text = f"{question_text} {options_text} {explanation_text}".lower()
    scores = {}
    for domain, info in domains.items():
        score = 0
        for kw in info.get("keywords", []):
            occurrences = full_text.count(kw.lower())
            if occurrences > 0:
                score += occurrences * len(kw)
        scores[domain] = score
    best = max(scores, key=scores.get)
    if scores[best] == 0:
        return None
    return best


def split_into_questions(text):
    """Split markdown text into raw question blocks."""
    text = text.replace("\r\n", "\n")

    # Split by "Question N" pattern (handles Q/q prefix, missing prefix)
    parts = re.split(r"\n(?:Q|q)?uestion\s+(\d+)\s*\n", text)

    blocks = []

    # Handle text before first "Question N" (some files have Q1 without header)
    preamble = parts[0].strip()
    if preamble and "Overall explanation" in preamble:
        blocks.append(("1", preamble))

    # Process matched pairs
    i = 1
    while i < len(parts) - 1:
        qnum = parts[i]
        body = parts[i + 1]
        blocks.append((qnum, body.strip()))
        i += 2

    return blocks


def parse_question_block(raw_body, qnum, cert_key, source_name, domains, default_domain):
    """Parse a single question block into structured data."""
    lines = raw_body.split("\n")

    # Remove status lines
    STATUS_LINES = {"Skipped", "Incorrect", "Correct"}
    cleaned = [l for l in lines if l.strip() not in STATUS_LINES]
    text = "\n".join(cleaned)

    # Split at "Overall explanation"
    expl_match = re.split(r"\nOverall explanation\s*\n?", text, maxsplit=1)
    qo_part = expl_match[0].strip()
    explanation = expl_match[1].strip() if len(expl_match) > 1 else ""

    # Clean explanation: remove trailing doc references
    explanation = re.sub(
        r"\s*For more detailed information,?\s*refer to the official Snowflake documentation\.?\s*$",
        "",
        explanation,
    ).strip()

    MARKER_MAP = {
        "Correct answer": "correct_single",
        "Correct selection": "correct_multi",
        "Your answer is incorrect": "wrong",
    }

    qo_lines = qo_part.split("\n")

    # Find first marker line
    first_marker_idx = None
    for i, line in enumerate(qo_lines):
        if line.strip() in MARKER_MAP:
            first_marker_idx = i
            break

    if first_marker_idx is None:
        return None

    # Boundary A: find last "?" line before first marker
    q_mark_end = -1
    for i in range(first_marker_idx - 1, -1, -1):
        if qo_lines[i].strip().endswith("?"):
            q_mark_end = i + 1
            for j in range(i + 1, first_marker_idx):
                if qo_lines[j].strip() == "":
                    q_mark_end = j
                    break
            break

    # Boundary B: last blank line before first marker
    q_blank_end = -1
    for i in range(first_marker_idx - 1, -1, -1):
        if qo_lines[i].strip() == "":
            q_blank_end = i
            break

    # Fallback: first blank line
    q_fallback = first_marker_idx
    for i, line in enumerate(qo_lines):
        if line.strip() == "" and i > 0:
            q_fallback = i
            break

    def _parse_from_boundary(q_end):
        remaining = qo_lines[q_end:]
        segments = []
        cur_marker = None
        cur_lines = []

        for line in remaining:
            s = line.strip()
            if s == "":
                if cur_lines:
                    segments.append((cur_marker, cur_lines[:]))
                    cur_marker = None
                    cur_lines = []
                continue
            if s in MARKER_MAP:
                if cur_lines:
                    segments.append((cur_marker, cur_lines[:]))
                    cur_lines = []
                cur_marker = MARKER_MAP[s]
                continue
            cur_lines.append(s)

        if cur_lines:
            segments.append((cur_marker, cur_lines[:]))

        opts = []
        corr = []
        multi = False

        for marker, content_lines in segments:
            if not content_lines:
                continue
            is_numbered = (
                len(content_lines) > 1
                and all(re.match(r"^\d+[\.\)]\s", l) for l in content_lines)
            )
            if len(content_lines) > 1 and not is_numbered:
                for ci, line in enumerate(content_lines):
                    if marker in ("correct_single", "correct_multi") and ci == 0:
                        corr.append(len(opts))
                        if marker == "correct_multi":
                            multi = True
                    opts.append(line)
            else:
                opt_text = "\n".join(content_lines)
                if marker in ("correct_single", "correct_multi"):
                    corr.append(len(opts))
                    if marker == "correct_multi":
                        multi = True
                opts.append(opt_text)

        q_text = "\n".join(qo_lines[:q_end]).strip()
        q_text = re.sub(r"\n{3,}", "\n\n", q_text)
        return q_text, opts, corr, multi

    # Try boundaries and pick best result
    best_q = ""
    best_opts = []
    best_corr = []
    best_multi = False

    candidates = []
    if q_mark_end > 0:
        candidates.append(q_mark_end)
    if q_blank_end > 0 and q_blank_end != q_mark_end:
        candidates.append(q_blank_end)
    if not candidates:
        candidates.append(q_fallback)

    for boundary in candidates:
        q_text, opts, corr, multi = _parse_from_boundary(boundary)
        if len(opts) >= 2 and len(corr) >= 1:
            if 3 <= len(opts) <= 8:
                best_q, best_opts, best_corr, best_multi = q_text, opts, corr, multi
                break
            elif len(opts) > len(best_opts):
                best_q, best_opts, best_corr, best_multi = q_text, opts, corr, multi

    if len(best_opts) < 2:
        for boundary in candidates:
            q_text, opts, corr, multi = _parse_from_boundary(boundary)
            if len(opts) > len(best_opts):
                best_q, best_opts, best_corr, best_multi = q_text, opts, corr, multi

    question_text = best_q
    options = best_opts
    correct_indices = best_corr
    is_multi = best_multi

    # Clean up options
    cleaned_options = []
    for opt in options:
        steps = re.findall(r"^\d+\.\s+.+$", opt, re.MULTILINE)
        if len(steps) >= 2 and opt.strip().startswith(("1.", "1 ")):
            cleaned_options.append(opt)
        else:
            cleaned_options.append(re.sub(r"\s+", " ", opt).strip())

    if not cleaned_options or not question_text:
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

    # Classify domain
    opts_text = " ".join(cleaned_options)
    domain = default_domain
    if domains:
        matched = classify_domain(question_text, opts_text, explanation, domains)
        if matched:
            domain = matched

    return {
        "id": f"{cert_key}_{source_name}_q{qnum}",
        "source": f"{cert_key}_{source_name}",
        "question_num": int(qnum),
        "question": question_text,
        "options": [{"text": o, "explanation": ""} for o in cleaned_options],
        "correct_indices": correct_indices,
        "multi_select": is_multi or len(correct_indices) > 1,
        "multi_select_count": max(multi_count, len(correct_indices)),
        "overall_explanation": explanation,
        "domain_raw": "",
        "domain": domain,
        "archived": False,
    }


def parse_file(filepath, cert_key, source_name, domains, default_domain):
    """Parse a single test markdown file."""
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()

    blocks = split_into_questions(text)
    questions = []
    for qnum, body in blocks:
        q = parse_question_block(body, qnum, cert_key, source_name, domains, default_domain)
        if q:
            questions.append(q)
        else:
            print(f"  WARN: Could not parse {source_name} Q{qnum}")

    return questions


def print_stats(all_questions):
    """Print validation stats."""
    print(f"\nTotal questions: {len(all_questions)}")

    # Domain distribution
    domain_counts = {}
    for q in all_questions:
        d = q["domain"]
        domain_counts[d] = domain_counts.get(d, 0) + 1
    print("\nDomain distribution:")
    for d, c in sorted(domain_counts.items()):
        print(f"  {d}: {c}")

    # Multi-select stats
    multi = sum(1 for q in all_questions if q["multi_select"])
    print(f"\nMulti-select: {multi}")
    print(f"Single-select: {len(all_questions) - multi}")

    # Option count distribution
    opt_counts = {}
    for q in all_questions:
        n = len(q["options"])
        opt_counts[n] = opt_counts.get(n, 0) + 1
    print("\nOption counts:")
    for n, c in sorted(opt_counts.items()):
        print(f"  {n} options: {c} questions")

    # Validation warnings
    bad_correct = [q for q in all_questions if not q["correct_indices"]]
    if bad_correct:
        print(f"\nWARNING: {len(bad_correct)} questions with no correct answer:")
        for q in bad_correct:
            print(f"  {q['id']}: {q['question'][:80]}...")

    bad_opts = [q for q in all_questions if len(q["options"]) < 3]
    if bad_opts:
        print(f"\nWARNING: {len(bad_opts)} questions with < 3 options:")
        for q in bad_opts:
            print(f"  {q['id']}: {len(q['options'])} opts - {q['question'][:60]}...")

    no_expl = [q for q in all_questions if not q["overall_explanation"]]
    if no_expl:
        print(f"\nWARNING: {len(no_expl)} questions with no explanation")


def main():
    parser = argparse.ArgumentParser(
        description="Parse Udemy-style markdown test files into standard question JSON.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python Scripts/parse_questions.py de output.json tests/test1.md tests/test2.md
  python Scripts/parse_questions.py genai output.json tests/*.md --domains domains.json
  python Scripts/parse_questions.py core output.json test.md --default-domain "Domain 1: Core"
        """,
    )
    parser.add_argument("cert_key", help="Short cert name for ID prefix (e.g., genai, de, core)")
    parser.add_argument("output", help="Output JSON file path")
    parser.add_argument("files", nargs="+", help="Markdown test file(s) to parse")
    parser.add_argument("--domains", help="JSON file with domain keyword config for auto-classification")
    parser.add_argument("--default-domain", default="Untagged", help="Domain when no keywords match (default: Untagged)")
    parser.add_argument("--append", action="store_true", help="Append to existing output file instead of overwriting")

    args = parser.parse_args()

    # Load domain config if provided
    domains = None
    if args.domains:
        with open(args.domains, "r", encoding="utf-8") as f:
            domains = json.load(f)
        print(f"Loaded {len(domains)} domain definitions from {args.domains}")

    # Load existing questions if appending
    all_questions = []
    if args.append and os.path.exists(args.output):
        with open(args.output, "r", encoding="utf-8") as f:
            all_questions = json.load(f)
        print(f"Loaded {len(all_questions)} existing questions from {args.output}")

    # Parse each file
    for i, fpath in enumerate(args.files, 1):
        if not os.path.exists(fpath):
            print(f"SKIP: {fpath} not found")
            continue
        source_name = f"test{i}"
        print(f"Parsing {fpath} (source: {args.cert_key}_{source_name})...")
        qs = parse_file(fpath, args.cert_key, source_name, domains, args.default_domain)
        print(f"  Parsed {len(qs)} questions")
        all_questions.extend(qs)

    # Print stats
    print_stats(all_questions)

    # Write output
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(all_questions, f, indent=2, ensure_ascii=False)
    print(f"\nWritten {len(all_questions)} questions to: {args.output}")


if __name__ == "__main__":
    main()
