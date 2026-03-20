"""
Parse SnowPro Gen AI (AIG-C01) Udemy questions into structured JSON.
Same format as Architect: blank-line separated, "Correct answer/selection" markers.
Includes auto-tagging to 5 study domains by keyword matching.

Source files: Snow_specialist_gen_ai/AI_GES_C01/ (6 files, ~556 questions)
Note: files 1-2 have double underscore (gen__ai), files 3-6 have single (gen_ai).
"""
import json
import re
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_DIR = os.path.join(os.path.dirname(BASE), "Snow_specialist_gen_ai", "AI_GES_C01")

CONTROL_LINES = {
    "Correct answer", "Correct selection", "Your answer is correct",
    "Your answer is incorrect", "Overall explanation", "Domain",
    "Explanation", "Skipped", "Incorrect", "Correct",
}


def is_control(line):
    s = line.strip()
    if s in CONTROL_LINES:
        return True
    if s.startswith("Your answer is") or s.startswith("Your selection is"):
        return True
    if re.match(r"^[Qq]uestion\s+\d+$", s):
        return True
    return False


def detect_multi_select(question_text):
    t = question_text.lower()
    if "select all that apply" in t or "choose all that apply" in t:
        return -1
    m = re.search(r"\((?:select|choose)\s+(\d+)\)", t, re.IGNORECASE)
    if m:
        return int(m.group(1))
    if "choose two" in t or "select two" in t:
        return 2
    if "choose three" in t or "select three" in t:
        return 3
    return 0


def parse_gen_ai(filepath, source_label):
    """Parse Gen AI test files (same format as Architect/Core Course 1)."""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    content = re.sub(r"^uestion\s+(\d+)", r"Question \1", content, flags=re.MULTILINE)
    blocks = re.split(r"(?=^Question\s+\d+\s*$)", content, flags=re.MULTILINE)

    questions = []
    for block in blocks:
        block = block.strip()
        if not block:
            continue

        blines = block.split("\n")
        m = re.match(r"^Question\s+(\d+)$", blines[0])
        if not m:
            continue

        q_num = int(m.group(1))

        correct_markers = []
        overall_idx = None

        for j, line in enumerate(blines):
            s = line.strip()
            if s in ("Correct answer", "Correct selection"):
                correct_markers.append(j)
            if s == "Overall explanation" and overall_idx is None:
                overall_idx = j

        if not correct_markers or overall_idx is None:
            continue

        status_idx = 1
        if status_idx < len(blines) and blines[status_idx].strip() in ("Skipped", "Incorrect", "Correct"):
            content_start = status_idx + 1
        else:
            content_start = status_idx

        correct_next_indices = set()
        for cm in correct_markers:
            j = cm + 1
            while j < overall_idx:
                s = blines[j].strip()
                if s == "" or is_control(blines[j]):
                    j += 1
                    continue
                correct_next_indices.add(j)
                break

        q_text_parts = []
        all_content = []
        found_question_end = False

        for j in range(content_start, overall_idx):
            s = blines[j].strip()
            if s == "" or is_control(blines[j]):
                continue

            is_correct = j in correct_next_indices

            if not found_question_end:
                if is_correct:
                    found_question_end = True
                    all_content.append((j, s, True))
                elif q_text_parts and (
                    q_text_parts[-1].endswith("?") or
                    q_text_parts[-1].endswith(":") or
                    q_text_parts[-1].endswith(")")
                ):
                    found_question_end = True
                    all_content.append((j, s, False))
                else:
                    q_text_parts.append(s)
            else:
                all_content.append((j, s, is_correct))

        q_text = " ".join(q_text_parts).strip()

        options = []
        correct_indices = []
        seen = set()
        for _, text, is_corr in all_content:
            if text in seen:
                continue
            seen.add(text)
            if is_corr:
                correct_indices.append(len(options))
            options.append({"text": text, "explanation": ""})

        # Overall explanation
        overall_lines = []
        domain_raw = ""
        j = overall_idx + 1
        in_domain = False
        while j < len(blines):
            s = blines[j].strip()
            if re.match(r"^[Qq]uestion\s+\d+$", s):
                break
            if s == "Domain":
                in_domain = True
                j += 1
                continue
            if in_domain and s:
                domain_raw = s
                in_domain = False
                j += 1
                continue
            if s and not in_domain:
                overall_lines.append(s)
            j += 1
        overall_exp = " ".join(overall_lines).strip()

        multi_count = detect_multi_select(q_text)
        is_multi = multi_count != 0 or len(correct_indices) > 1

        if q_text and options:
            questions.append({
                "id": f"{source_label}_q{q_num}",
                "source": source_label,
                "question_num": q_num,
                "question": q_text,
                "options": options,
                "correct_indices": correct_indices,
                "multi_select": is_multi,
                "multi_select_count": multi_count if multi_count > 0 else len(correct_indices),
                "overall_explanation": overall_exp,
                "domain_raw": domain_raw,
                "domain": "Untagged",
            })

    return questions


# ── Auto-tagging by keyword for official Gen AI exam domains ──
# Official domains from SnowPro Specialty: Gen AI Study Guide
# Domain 4 (Document AI) was removed from exam March 1, 2026 but questions still exist
GEN_AI_DOMAIN_KEYWORDS = {
    "Domain 1: Snowflake for Gen AI Overview": [
        # 1.1 Snowflake Gen AI principles, features, best practices
        "Snowflake Cortex", "Cortex", "Cortex LLM",
        "Cortex Search", "Cortex Analyst", "Cortex Fine-tuning", "Cortex Agents",
        "Snowflake Copilot", "Copilot",
        "RBAC", "role-based access", "guardrail", "guardrails",
        "CORTEX_MODELS_ALLOWLIST", "CORTEX_MODELS_ALLOW_LIST",
        "LLM Playground", "REST API",
        "Hugging Face", "Model Registry", "custom model",
        # 1.2 Gen AI capabilities
        "vector embedding", "EMBED_TEXT", "EMBED_TEXT_768", "EMBED_TEXT_1024",
        "fine-tuning", "fine tuning", "FINETUNE",
        "RAG", "retrieval-augmented", "retrieval augmented",
        "semantic model", "semantic view", "YAML",
        "text-to-SQL", "NL-to-SQL", "structured data", "unstructured data",
        "cross-region inference", "CORTEX_ENABLED_CROSS_REGION",
        "Snowpark Container Services", "SPCS", "container service",
        "VECTOR_INNER_PRODUCT", "VECTOR_L1_DISTANCE", "VECTOR_L2_DISTANCE",
        "VECTOR_COSINE_SIMILARITY", "vector data type",
    ],
    "Domain 2: Snowflake Gen AI & LLM Functions": [
        # 2.1 Apply Gen AI and LLM functions
        "COMPLETE", "TRY_COMPLETE", "CORTEX.COMPLETE",
        "CLASSIFY_TEXT", "EXTRACT_ANSWER", "PARSE_DOCUMENT",
        "SENTIMENT", "SUMMARIZE", "TRANSLATE",
        "COUNT_TOKENS", "SPLIT_TEXT_RECURSIVE",
        "structured output", "JSON output",
        "task-specific function", "helper function",
        "choosing a model", "model size", "latency", "capability",
        # 2.2 Data analysis use cases
        "Cortex Analyst", "Verified Query Repository", "VQR",
        "suggested questions", "custom_instructions",
        "CORTEX PARSE_DOCUMENT",
        # 2.3 Chat interfaces
        "chat", "multi-turn", "conversation", "Streamlit",
        "chat interface", "chat conversation",
        # 2.4 Cortex in data pipelines
        "data pipeline", "data enrichment", "data augmentation",
        "data transformation", "transcript", "extracting data from text",
        # 2.5 Third-party models
        "Snowpark Container Services", "SPCS", "Docker", "docker image",
        "specification file", "compute pool", "image repository",
        "Model Registry", "logging the model", "calling the model",
        # Vector functions
        "cosine similarity", "cosine distance", "inner product",
        "L2 distance", "L1 distance", "vector function",
        "embedding", "vector", "similarity search",
        # Search
        "Cortex Search", "search service", "hybrid search",
        "chunk", "chunking", "SPLIT_TEXT",
        # General LLM terms
        "LLM", "large language model", "prompt",
        "token", "tokenization", "context window",
        "temperature", "top_p", "system prompt",
    ],
    "Domain 3: Snowflake Gen AI Governance": [
        # 3.1 Model access controls
        "CORTEX_MODELS_ALLOWLIST", "CORTEX_MODELS_ALLOW_LIST",
        "model access", "restrict access", "restrict model",
        "data safety", "data security", "data leaving",
        "REST API authentication", "authentication method",
        # 3.2 Guardrails
        "Cortex Guard", "guardrail", "guardrails",
        "hallucination", "bias", "harmful", "unsafe",
        "error condition", "content safety", "filter",
        # 3.3 Monitor and optimize costs
        "cost", "credit", "consumption", "metering",
        "CORTEX_FUNCTIONS_USAGE_HISTORY", "CORTEX_FUNCTIONS_QUERY_USAGE_HISTORY",
        "METERING_DAILY_HISTORY", "CORTEX_SEARCH_DAILY_USAGE_HISTORY",
        "Snowflake Service Consumption", "usage quota",
        "minimize token", "token cost",
        # 3.4 AI observability
        "AI observability", "observability",
        "evaluation metric", "tracing", "logging", "event table",
        "Trulens", "TruLens SDK",
        # General governance
        "governance", "privilege", "GRANT", "REVOKE",
        "access control", "security", "audit", "auditing",
        "monitoring", "compliance", "privacy",
        "prompt injection", "SQL injection",
        "data governance", "PII", "sensitive data",
        "cost attribution", "cost tracking",
    ],
    "Domain 4: Snowflake Document AI": [
        # 4.1 Set up Document AI
        "Document AI", "document intelligence",
        "SNOWFLAKE.ML.DOCUMENT_INTELLIGENCE",
        # 4.2 Prepare documents
        "upload document", "train the model",
        "question optimization", "format", "size limit",
        # 4.3 Extract values
        "PREDICT", "model_build", "extraction",
        "data pipeline", "automation",
        # 4.4 Troubleshoot
        "GET_PRESIGNED_URL", "presigned URL",
        "document processing", "document extraction",
        "OCR", "invoice", "receipt", "form extraction",
    ],
}


def auto_tag_gen_ai(question_text, options_text="", domain_raw=""):
    combined = (question_text + " " + options_text + " " + domain_raw).lower()
    scores = {}
    for domain, keywords in GEN_AI_DOMAIN_KEYWORDS.items():
        score = 0
        for kw in keywords:
            if kw.lower() in combined:
                score += len(kw.split())
        if score > 0:
            scores[domain] = score

    if not scores:
        return "Untagged"

    best = max(scores, key=scores.get)
    if scores[best] >= 2:
        return best
    return "Untagged"


def main():
    all_questions = []

    # File patterns: files 1-2 have gen__ai (double underscore), 3-6 have gen_ai
    file_patterns = [
        ("course_01_gen__ai_test example_1.md", "genai_test1"),
        ("course_01_gen__ai_test example_2.md", "genai_test2"),
        ("course_01_gen_ai_test example_3.md", "genai_test3"),
        ("course_01_gen_ai_test example_4.md", "genai_test4"),
        ("course_01_gen_ai_test example_5.md", "genai_test5"),
        ("course_01_gen_ai_test example_6.md", "genai_test6"),
    ]

    print("=== SnowPro Gen AI (AIG-C01) ===")
    for filename, label in file_patterns:
        fp = os.path.join(SOURCE_DIR, filename)
        if not os.path.exists(fp):
            print(f"  {label}: FILE NOT FOUND at {fp}")
            continue
        qs = parse_gen_ai(fp, label)
        print(f"  {label}: {len(qs)} questions")
        all_questions.extend(qs)

    # Auto-tag
    print("\n=== Auto-tagging ===")
    untagged_before = sum(1 for q in all_questions if q["domain"] == "Untagged")
    for q in all_questions:
        if q["domain"] == "Untagged":
            opts_text = " ".join(o["text"] for o in q["options"])
            q["domain"] = auto_tag_gen_ai(q["question"], opts_text, q.get("domain_raw", ""))
    untagged_after = sum(1 for q in all_questions if q["domain"] == "Untagged")
    print(f"  Before: {untagged_before} untagged")
    print(f"  After:  {untagged_after} untagged")
    print(f"  Tagged: {untagged_before - untagged_after}")

    # Stats
    print(f"\nTotal: {len(all_questions)}")
    from collections import Counter
    domain_counts = Counter(q["domain"] for q in all_questions)
    print("\nDomain distribution:")
    for d, c in sorted(domain_counts.items()):
        print(f"  {d}: {c}")

    multi = sum(1 for q in all_questions if q.get("multi_select"))
    few_opts = sum(1 for q in all_questions if len(q["options"]) < 2)
    no_correct = sum(1 for q in all_questions if not q["correct_indices"])
    print(f"\nMulti-select: {multi}")
    print(f"<2 options: {few_opts}")
    print(f"0 correct: {no_correct}")

    # Save
    out_path = os.path.join(BASE, "gen_ai_questions.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(all_questions, f, indent=2, ensure_ascii=False)
    print(f"\nSaved to: {out_path}")


if __name__ == "__main__":
    main()
