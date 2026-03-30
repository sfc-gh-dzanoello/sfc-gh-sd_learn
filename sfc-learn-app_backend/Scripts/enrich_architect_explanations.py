#!/usr/bin/env python3
"""
Enrich Architect Questions with Per-Option Explanations
========================================================
Reads architect_questions.json, generates detailed per-option explanations
using Snowflake Cortex AI, and writes the enriched JSON back.

Usage:
    # Full run (all questions with empty explanations):
    python Scripts/enrich_architect_explanations.py

    # Dry run (show what would be processed, no changes):
    python Scripts/enrich_architect_explanations.py --dry-run

    # Process specific question IDs only:
    python Scripts/enrich_architect_explanations.py --ids architect_test1_q1 architect_test2_q34

    # Process a specific domain only:
    python Scripts/enrich_architect_explanations.py --domain "Domain 1.0"

    # Use local fallback (no Snowflake connection needed):
    python Scripts/enrich_architect_explanations.py --local

Self-service: To manually edit explanations, just open architect_questions.json
and fill in the "explanation" field for any option. This script will skip
any option that already has a non-empty explanation.
"""

import json
import os
import sys
import re
import argparse
import time
from pathlib import Path

# ── Paths ──────────────────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).resolve().parent
APP_DIR = SCRIPT_DIR.parent
QUESTIONS_FILE = APP_DIR / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "architect_questions.json"
SUBTOPIC_DIR = APP_DIR / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "by_subtopic"
BACKUP_SUFFIX = ".backup"


def load_questions(path: Path) -> list:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_questions(path: Path, questions: list, backup: bool = True):
    if backup and path.exists():
        backup_path = path.with_suffix(path.suffix + BACKUP_SUFFIX)
        import shutil
        shutil.copy2(path, backup_path)
        print(f"  Backup saved: {backup_path.name}")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(questions, f, indent=2, ensure_ascii=False)
    print(f"  Saved {len(questions)} questions to {path.name}")


def load_exam_traps() -> dict:
    """Load exam_traps from all subtopic question files, keyed by subtopic."""
    traps = {}
    if not SUBTOPIC_DIR.exists():
        return traps
    for folder in sorted(SUBTOPIC_DIR.iterdir()):
        qfile = folder / "questions.json"
        if qfile.exists():
            with open(qfile, "r", encoding="utf-8") as f:
                data = json.load(f)
            st = data.get("sub_topic", folder.name)
            if data.get("exam_traps"):
                traps[st] = data["exam_traps"]
    return traps


def needs_enrichment(question: dict) -> bool:
    """Check if any option in this question has an empty explanation."""
    return any(not opt.get("explanation") for opt in question.get("options", []))


def build_prompt(question: dict, exam_traps: list = None) -> str:
    """Build a prompt for Cortex AI to generate per-option explanations."""
    q = question
    correct_indices = set(q.get("correct_indices", []))
    options_text = ""
    for i, opt in enumerate(q["options"]):
        marker = "CORRECT" if i in correct_indices else "WRONG"
        options_text += f"  Option {chr(65+i)} [{marker}]: {opt['text']}\n"

    trap_context = ""
    if exam_traps:
        trap_lines = []
        for t in exam_traps[:4]:  # max 4 traps for context
            trap_lines.append(f"  - Trap: {t['trap']}")
            trap_lines.append(f"    Why confusing: {t['why_confusing']}")
        trap_context = "\nExam traps for this topic:\n" + "\n".join(trap_lines) + "\n"

    prompt = f"""You are a Snowflake Architect certification exam coach. Generate a brief, exam-focused explanation for EACH option in this question.

Question: {q['question']}

Options:
{options_text}
Overall explanation: {q.get('overall_explanation', 'N/A')}

Domain: {q.get('domain', 'N/A')}
Subtopic: {q.get('sub_topic_name', 'N/A')}
Difficulty: {q.get('difficulty', 'N/A')}
{trap_context}
For each option, write 1-2 concise sentences explaining:
- If CORRECT: Why this is right, what Snowflake concept it tests
- If WRONG: Why this is wrong, what the common misconception is, what trap exam-takers fall into

IMPORTANT formatting rules:
- Return ONLY a JSON array of strings, one per option, in order (A, B, C, D, ...)
- Each string should be the explanation for that option
- For correct options, start with "Correct." then the explanation
- For wrong options, start with "Incorrect." then the explanation
- Keep each explanation to 1-2 sentences (max 200 chars)
- Do NOT include option letters or labels in the explanation text
- Return valid JSON only, no markdown, no code fences

Example output format:
["Correct. Multi-cluster warehouses scale out to handle concurrent queries, which directly addresses the concurrency bottleneck described.", "Incorrect. Scaling up warehouse size improves single-query performance but does not address concurrent user contention."]"""

    return prompt


def generate_explanations_cortex(questions_batch: list, exam_traps_map: dict, connection) -> list:
    """Generate explanations using Snowflake Cortex AI via SQL."""
    results = []
    for q in questions_batch:
        if not needs_enrichment(q):
            results.append(q)
            continue

        traps = exam_traps_map.get(q.get("sub_topic", ""), [])
        prompt = build_prompt(q, traps)

        # Escape single quotes for SQL
        escaped_prompt = prompt.replace("\\", "\\\\").replace("'", "\\'")

        sql = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'claude-3-5-sonnet',
            '{escaped_prompt}'
        ) AS result
        """
        try:
            cursor = connection.cursor()
            cursor.execute(sql)
            row = cursor.fetchone()
            raw = row[0] if row else None
            cursor.close()

            if raw:
                explanations = parse_ai_response(raw, len(q["options"]))
                if explanations:
                    for i, opt in enumerate(q["options"]):
                        if not opt.get("explanation") and i < len(explanations):
                            opt["explanation"] = explanations[i]
        except Exception as e:
            print(f"  WARNING: Cortex call failed for {q['id']}: {e}")

        results.append(q)
    return results


def generate_explanations_local(questions: list, exam_traps_map: dict) -> list:
    """Generate explanations locally using the overall_explanation and correct_indices.
    This is a deterministic fallback that doesn't need Snowflake Cortex."""
    results = []
    for q in questions:
        if not needs_enrichment(q):
            results.append(q)
            continue

        correct_indices = set(q.get("correct_indices", []))
        overall = q.get("overall_explanation", "")
        traps = exam_traps_map.get(q.get("sub_topic", ""), [])

        for i, opt in enumerate(q["options"]):
            if opt.get("explanation"):
                continue  # skip already filled

            opt_text = opt["text"].strip()
            is_correct = i in correct_indices

            if is_correct:
                # Extract relevant sentence from overall explanation
                explanation = _extract_correct_reason(opt_text, overall, q)
                opt["explanation"] = f"Correct. {explanation}"
            else:
                # Extract why-wrong from overall explanation
                explanation = _extract_wrong_reason(opt_text, overall, traps)
                opt["explanation"] = f"Incorrect. {explanation}"

        results.append(q)
    return results


def _extract_correct_reason(opt_text: str, overall: str, question: dict) -> str:
    """Extract a reason why this option is correct from overall explanation."""
    # Try to find a sentence in overall that relates to this option
    opt_words = set(opt_text.lower().split())
    sentences = re.split(r'(?<=[.!?])\s+', overall)

    best_sentence = ""
    best_score = 0
    for sent in sentences:
        # Skip sentences about "other options" or wrong answers
        if "other option" in sent.lower() or "about other" in sent.lower():
            continue
        sent_words = set(sent.lower().split())
        overlap = len(opt_words & sent_words)
        if overlap > best_score:
            best_score = overlap
            best_sentence = sent.strip()

    if best_sentence and best_score >= 2:
        # Trim to max ~180 chars
        if len(best_sentence) > 180:
            best_sentence = best_sentence[:177] + "..."
        return best_sentence
    return "This is the correct answer based on Snowflake documentation and best practices."


def _extract_wrong_reason(opt_text: str, overall: str, traps: list) -> str:
    """Extract a reason why this option is wrong."""
    opt_words = set(opt_text.lower().split())
    sentences = re.split(r'(?<=[.!?])\s+', overall)

    # Look in overall explanation, especially the "About other options" section
    about_others = False
    best_sentence = ""
    best_score = 0
    for sent in sentences:
        if "about other" in sent.lower() or "other option" in sent.lower():
            about_others = True
            continue
        if about_others or True:  # search everywhere
            sent_words = set(sent.lower().split())
            overlap = len(opt_words & sent_words)
            if overlap > best_score:
                best_score = overlap
                best_sentence = sent.strip()

    # Also check exam traps
    for trap in traps:
        trap_text = trap.get("why_confusing", "")
        trap_words = set(trap_text.lower().split())
        overlap = len(opt_words & trap_words)
        if overlap > best_score:
            best_score = overlap
            best_sentence = trap_text.strip()

    if best_sentence and best_score >= 2:
        if len(best_sentence) > 180:
            best_sentence = best_sentence[:177] + "..."
        return best_sentence
    return "This option does not align with Snowflake's recommended approach for this scenario."


def parse_ai_response(raw: str, num_options: int) -> list:
    """Parse the AI response into a list of explanation strings."""
    # Try direct JSON parse
    try:
        result = json.loads(raw)
        if isinstance(result, list) and len(result) >= num_options:
            return [str(x).strip() for x in result[:num_options]]
    except json.JSONDecodeError:
        pass

    # Try extracting JSON array from response text
    match = re.search(r'\[.*?\]', raw, re.DOTALL)
    if match:
        try:
            result = json.loads(match.group())
            if isinstance(result, list) and len(result) >= num_options:
                return [str(x).strip() for x in result[:num_options]]
        except json.JSONDecodeError:
            pass

    return None


def get_snowflake_connection():
    """Get a Snowflake connection using snowflake-connector-python."""
    try:
        import snowflake.connector
        conn = snowflake.connector.connect(
            connection_name="SNOWHOUSE_AWS_US_WEST_2",
            authenticator="externalbrowser"
        )
        return conn
    except Exception as e:
        print(f"  Could not connect to Snowflake: {e}")
        return None


def main():
    parser = argparse.ArgumentParser(description="Enrich architect question explanations")
    parser.add_argument("--dry-run", action="store_true", help="Show stats without modifying")
    parser.add_argument("--local", action="store_true", help="Use local extraction (no Cortex AI)")
    parser.add_argument("--ids", nargs="+", help="Process specific question IDs only")
    parser.add_argument("--domain", type=str, help="Process a specific domain (e.g. 'Domain 1.0')")
    parser.add_argument("--no-backup", action="store_true", help="Skip creating backup file")
    args = parser.parse_args()

    print("=" * 60)
    print("Architect Questions - Per-Option Explanation Enrichment")
    print("=" * 60)

    # Load data
    print(f"\nLoading questions from: {QUESTIONS_FILE.name}")
    questions = load_questions(QUESTIONS_FILE)
    print(f"  Total questions: {len(questions)}")

    print(f"\nLoading exam traps from: {SUBTOPIC_DIR.name}/")
    exam_traps_map = load_exam_traps()
    print(f"  Subtopics with traps: {len(exam_traps_map)}")

    # Filter questions
    to_process = questions
    if args.ids:
        to_process = [q for q in questions if q["id"] in args.ids]
        print(f"\n  Filtered to {len(to_process)} questions by ID")
    elif args.domain:
        to_process = [q for q in questions if args.domain.lower() in q.get("domain", "").lower()]
        print(f"\n  Filtered to {len(to_process)} questions in domain '{args.domain}'")

    # Count what needs enrichment
    need_enrichment = [q for q in to_process if needs_enrichment(q)]
    empty_opts = sum(1 for q in to_process for o in q["options"] if not o.get("explanation"))
    total_opts = sum(len(q["options"]) for q in to_process)

    print(f"\n  Questions needing enrichment: {len(need_enrichment)}/{len(to_process)}")
    print(f"  Empty option explanations: {empty_opts}/{total_opts}")

    if args.dry_run:
        print("\n  [DRY RUN] No changes made.")
        # Show breakdown by domain
        domain_counts = {}
        for q in need_enrichment:
            d = q.get("domain", "unknown")
            domain_counts[d] = domain_counts.get(d, 0) + 1
        print("\n  By domain:")
        for d, c in sorted(domain_counts.items()):
            print(f"    {d}: {c} questions")
        return

    if not need_enrichment:
        print("\n  All options already have explanations. Nothing to do!")
        return

    # Process
    if args.local:
        print("\n  Using LOCAL extraction mode (no Cortex AI)...")
        enriched = generate_explanations_local(need_enrichment, exam_traps_map)
    else:
        print("\n  Connecting to Snowflake Cortex AI...")
        conn = get_snowflake_connection()
        if conn:
            print("  Connected! Processing with Cortex AI...")
            enriched = []
            batch_size = 10
            for i in range(0, len(need_enrichment), batch_size):
                batch = need_enrichment[i:i + batch_size]
                print(f"  Processing batch {i // batch_size + 1}/{(len(need_enrichment) + batch_size - 1) // batch_size} ({len(batch)} questions)...")
                batch_result = generate_explanations_cortex(batch, exam_traps_map, conn)
                enriched.extend(batch_result)
                time.sleep(0.5)  # rate limiting
            conn.close()
        else:
            print("  Falling back to LOCAL extraction mode...")
            enriched = generate_explanations_local(need_enrichment, exam_traps_map)

    # Merge enriched questions back into full list
    enriched_map = {q["id"]: q for q in enriched}
    for i, q in enumerate(questions):
        if q["id"] in enriched_map:
            questions[i] = enriched_map[q["id"]]

    # Save
    print(f"\nSaving enriched questions...")
    save_questions(QUESTIONS_FILE, questions, backup=not args.no_backup)

    # Final stats
    remaining_empty = sum(1 for q in questions for o in q["options"] if not o.get("explanation"))
    print(f"\n  Empty explanations remaining: {remaining_empty}/{sum(len(q['options']) for q in questions)}")
    print("  Done!")


if __name__ == "__main__":
    main()
