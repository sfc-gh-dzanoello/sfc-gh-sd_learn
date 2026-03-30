#!/usr/bin/env python3
"""
Apply AI-generated per-option explanations to architect_questions.json.

Reads Cortex AI results from the downloaded stage file and merges
them into the main questions JSON, preserving any existing explanations.

Usage: python Scripts/apply_enrichment_results.py
"""
import gzip
import json
import re
import shutil
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
APP_DIR = SCRIPT_DIR.parent
QUESTIONS_FILE = APP_DIR / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "architect_questions.json"
RESULTS_FILE = SCRIPT_DIR / ".results" / "data"


def parse_ai_response(raw_response: str, num_options: int) -> list:
    """Parse AI response string into list of explanation strings."""
    if not raw_response:
        return None

    text = raw_response.strip()
    # Remove outer quotes if present
    if text.startswith('"') and text.endswith('"'):
        text = text[1:-1]
    text = text.replace('\\"', '"').replace('\\n', '\n')

    # Try direct JSON parse
    try:
        result = json.loads(text)
        if isinstance(result, list) and len(result) >= num_options:
            return [str(x).strip() for x in result[:num_options]]
    except json.JSONDecodeError:
        pass

    # Try extracting JSON array
    match = re.search(r'\[.*\]', text, re.DOTALL)
    if match:
        try:
            result = json.loads(match.group())
            if isinstance(result, list) and len(result) >= num_options:
                return [str(x).strip() for x in result[:num_options]]
        except json.JSONDecodeError:
            pass

    return None


def main():
    print("=" * 60)
    print("Applying AI Enrichment Results to architect_questions.json")
    print("=" * 60)

    # Load questions
    with open(QUESTIONS_FILE, "r", encoding="utf-8") as f:
        questions = json.load(f)
    print(f"Loaded {len(questions)} questions")

    # Count empty before
    empty_before = sum(1 for q in questions for o in q["options"] if not o.get("explanation"))
    total_opts = sum(len(q["options"]) for q in questions)
    print(f"Empty explanations before: {empty_before}/{total_opts}")

    # Load AI results
    with gzip.open(RESULTS_FILE, "rt", encoding="utf-8") as f:
        raw = f.read()

    results = {}
    for line in raw.strip().split("\n"):
        if not line.strip():
            continue
        obj = json.loads(line)
        qid = obj["question_id"]
        results[qid] = obj
    print(f"Loaded {len(results)} AI results")

    # Create backup
    backup_path = QUESTIONS_FILE.with_suffix(".json.pre_enrichment_backup")
    if not backup_path.exists():
        shutil.copy2(QUESTIONS_FILE, backup_path)
        print(f"Backup: {backup_path.name}")

    # Apply results
    applied = 0
    failed = 0
    skipped = 0

    for q in questions:
        qid = q["id"]
        if qid not in results:
            skipped += 1
            continue

        r = results[qid]
        num_opts = len(q["options"])
        explanations = parse_ai_response(r["ai_response"], num_opts)

        if not explanations:
            failed += 1
            print(f"  PARSE FAILED: {qid}")
            continue

        for i, opt in enumerate(q["options"]):
            if not opt.get("explanation") and i < len(explanations):
                opt["explanation"] = explanations[i]

        applied += 1

    print(f"\nResults: applied={applied}, failed={failed}, skipped={skipped}")

    # Save
    with open(QUESTIONS_FILE, "w", encoding="utf-8") as f:
        json.dump(questions, f, indent=2, ensure_ascii=False)

    # Count empty after
    empty_after = sum(1 for q in questions for o in q["options"] if not o.get("explanation"))
    print(f"Empty explanations after: {empty_after}/{total_opts}")
    print(f"Filled: {empty_before - empty_after} new explanations")
    print("Done!")


if __name__ == "__main__":
    main()
