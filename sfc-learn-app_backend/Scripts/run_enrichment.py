#!/usr/bin/env python3
"""
Process architect_questions.json and enrich each option's explanation field
using Snowflake Cortex AI via snowflake-connector-python.

This script:
1. Reads architect_questions.json
2. For each question with empty option explanations, calls Cortex AI
3. Parses the JSON response and fills in per-option explanations
4. Saves the enriched file (with backup)

Run: python Scripts/run_enrichment.py
"""
import json
import re
import sys
import time
import os
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
APP_DIR = SCRIPT_DIR.parent
QUESTIONS_FILE = APP_DIR / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "architect_questions.json"
SUBTOPIC_DIR = APP_DIR / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "by_subtopic"
PROGRESS_FILE = SCRIPT_DIR / ".enrichment_progress.json"


def load_exam_traps():
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


def build_prompt(q, exam_traps=None):
    correct_indices = set(q.get("correct_indices", []))
    opts = ""
    for i, opt in enumerate(q["options"]):
        marker = "CORRECT" if i in correct_indices else "WRONG"
        opts += f"  Option {chr(65+i)} [{marker}]: {opt['text']}\n"

    trap_ctx = ""
    if exam_traps:
        lines = []
        for t in exam_traps[:3]:
            lines.append(f"  - {t['trap']}: {t['why_confusing']}")
        trap_ctx = "\nExam traps for this topic:\n" + "\n".join(lines) + "\n"

    return f"""You are a Snowflake Architect certification exam coach. Generate a brief explanation for EACH option.

Question: {q['question']}

Options:
{opts}
Overall explanation: {q.get('overall_explanation', 'N/A')}
Domain: {q.get('domain', 'N/A')}
Subtopic: {q.get('sub_topic_name', 'N/A')}
{trap_ctx}
Rules:
- Return ONLY a JSON array of strings, one per option in order
- For correct options start with "Correct."
- For wrong options start with "Incorrect."
- 1-2 sentences each, max 200 chars per explanation
- Focus on WHY correct/wrong and common exam traps
- Valid JSON only, no markdown fences"""


def parse_response(raw, num_options):
    """Parse Cortex response into list of explanation strings."""
    if not raw:
        return None
    # Remove outer quotes if present
    text = raw.strip()
    if text.startswith('"') and text.endswith('"'):
        text = text[1:-1]
    # Unescape
    text = text.replace('\\"', '"').replace('\\n', '\n')
    
    # Try JSON parse
    try:
        result = json.loads(text)
        if isinstance(result, list) and len(result) >= num_options:
            return [str(x).strip() for x in result[:num_options]]
    except:
        pass
    
    # Try finding JSON array in text
    match = re.search(r'\[.*\]', text, re.DOTALL)
    if match:
        try:
            result = json.loads(match.group())
            if isinstance(result, list) and len(result) >= num_options:
                return [str(x).strip() for x in result[:num_options]]
        except:
            pass
    return None


def load_progress():
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE) as f:
            return json.load(f)
    return {"completed_ids": []}


def save_progress(progress):
    with open(PROGRESS_FILE, "w") as f:
        json.dump(progress, f)


def main():
    print("=" * 60)
    print("Enriching Architect Questions via Snowflake Cortex AI")
    print("=" * 60)

    # Load questions
    with open(QUESTIONS_FILE, "r", encoding="utf-8") as f:
        questions = json.load(f)
    print(f"Loaded {len(questions)} questions")

    # Load exam traps
    exam_traps_map = load_exam_traps()
    print(f"Loaded exam traps for {len(exam_traps_map)} subtopics")

    # Load progress (for resume capability)
    progress = load_progress()
    completed = set(progress["completed_ids"])
    print(f"Previously completed: {len(completed)} questions")

    # Find questions needing enrichment
    to_process = []
    for q in questions:
        if q["id"] in completed:
            continue
        if any(not opt.get("explanation") for opt in q["options"]):
            to_process.append(q)
    
    print(f"Questions to process: {len(to_process)}")
    
    if not to_process:
        print("Nothing to do!")
        return

    # Connect to Snowflake
    try:
        import snowflake.connector
        conn = snowflake.connector.connect(
            connection_name="SNOWHOUSE_AWS_US_WEST_2"
        )
        print("Connected to Snowflake!")
    except Exception as e:
        print(f"ERROR: Could not connect to Snowflake: {e}")
        print("Try: pip install snowflake-connector-python")
        sys.exit(1)

    # Create backup
    import shutil
    backup = QUESTIONS_FILE.with_suffix(".json.backup")
    if not backup.exists():
        shutil.copy2(QUESTIONS_FILE, backup)
        print(f"Backup created: {backup.name}")

    # Process questions
    q_map = {q["id"]: q for q in questions}
    cursor = conn.cursor()
    success = 0
    failed = 0

    for i, q in enumerate(to_process):
        traps = exam_traps_map.get(q.get("sub_topic", ""), [])
        prompt = build_prompt(q, traps)
        escaped = prompt.replace("\\", "\\\\").replace("'", "\\'")

        sql = f"SELECT SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet', '{escaped}') AS result"
        
        try:
            cursor.execute(sql)
            row = cursor.fetchone()
            raw = row[0] if row else None
            explanations = parse_response(raw, len(q["options"]))

            if explanations:
                for j, opt in enumerate(q["options"]):
                    if not opt.get("explanation") and j < len(explanations):
                        opt["explanation"] = explanations[j]
                q_map[q["id"]] = q
                completed.add(q["id"])
                success += 1
                print(f"  [{i+1}/{len(to_process)}] {q['id']} - OK ({len(explanations)} options)")
            else:
                failed += 1
                print(f"  [{i+1}/{len(to_process)}] {q['id']} - PARSE FAILED")

        except Exception as e:
            failed += 1
            print(f"  [{i+1}/{len(to_process)}] {q['id']} - ERROR: {str(e)[:80]}")

        # Save progress every 20 questions
        if (i + 1) % 20 == 0:
            progress["completed_ids"] = list(completed)
            save_progress(progress)
            # Also save questions
            final = [q_map.get(q2["id"], q2) for q2 in questions]
            with open(QUESTIONS_FILE, "w", encoding="utf-8") as f:
                json.dump(final, f, indent=2, ensure_ascii=False)
            print(f"  -- Checkpoint saved ({success} success, {failed} failed) --")

        time.sleep(0.3)  # Rate limiting

    cursor.close()
    conn.close()

    # Final save
    final = [q_map.get(q2["id"], q2) for q2 in questions]
    with open(QUESTIONS_FILE, "w", encoding="utf-8") as f:
        json.dump(final, f, indent=2, ensure_ascii=False)
    
    progress["completed_ids"] = list(completed)
    save_progress(progress)

    print(f"\nDone! Success: {success}, Failed: {failed}")
    remaining = sum(1 for q in final for o in q["options"] if not o.get("explanation"))
    print(f"Remaining empty explanations: {remaining}")


if __name__ == "__main__":
    main()
