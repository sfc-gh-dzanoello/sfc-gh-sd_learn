#!/usr/bin/env python3
"""
Split architect_questions.json into per-sub-topic files.

Creates a folder structure:
  architect_domains/by_subtopic/
    1_1_account_strategy/questions.json
    1_2_parameter_hierarchy/questions.json
    ...

Each file contains only the questions for that sub-topic,
plus a summary header with count and difficulty distribution.
"""

import json
import os
from collections import Counter, defaultdict

BASE = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),
    "certifications", "sfc-gh-sd-advanced", "architect_domains",
)

def main():
    qfile = os.path.join(BASE, "architect_questions.json")
    traps_file = os.path.join(BASE, "exam_traps_en.json")

    with open(qfile, "r") as f:
        questions = json.load(f)

    with open(traps_file, "r") as f:
        traps_data = json.load(f)

    # Build traps lookup
    traps_by_st = {}
    for entry in traps_data:
        traps_by_st[entry["sub_topic"]] = entry["traps"]

    # Group questions by sub_topic
    groups = defaultdict(list)
    for q in questions:
        st = q.get("sub_topic", "0.0")
        groups[st].append(q)

    # Create output directory
    out_dir = os.path.join(BASE, "by_subtopic")
    os.makedirs(out_dir, exist_ok=True)

    total_files = 0
    for st_id, qs in sorted(groups.items()):
        st_name = qs[0].get("sub_topic_name", "Unknown")
        folder_name = f"{st_id.replace('.', '_')}_{st_name.lower().replace(' ', '_').replace('&', 'and').replace('/', '_')}"
        folder_path = os.path.join(out_dir, folder_name)
        os.makedirs(folder_path, exist_ok=True)

        # Difficulty distribution
        diffs = Counter(q.get("difficulty", "unset") for q in qs)

        # Build output
        output = {
            "sub_topic": st_id,
            "sub_topic_name": st_name,
            "domain": qs[0].get("domain", ""),
            "total_questions": len(qs),
            "difficulty_distribution": dict(sorted(diffs.items())),
            "exam_traps": traps_by_st.get(st_id, []),
            "questions": qs,
        }

        outfile = os.path.join(folder_path, "questions.json")
        with open(outfile, "w") as f:
            json.dump(output, f, indent=2, ensure_ascii=False)

        total_files += 1
        print(f"  {folder_name}: {len(qs)} questions, {len(output['exam_traps'])} traps")

    print(f"\nGenerated {total_files} sub-topic files in {out_dir}")


if __name__ == "__main__":
    main()
