# How to Add a New Certification to the PS Platform

This checklist walks you through adding a new SnowPro certification exam to the study app.
No Python code changes are needed -- just files and JSON config.

---

## What You Need

- [ ] Udemy test markdown exports (1 or more `.md` files)
- [ ] The official exam guide (for domain names, weights, and tips)

---

## Step 1: Parse Your Questions

Use the generic parser to convert Udemy markdown exports into the standard JSON format:

```bash
python Scripts/parse_questions.py <cert_key> <output.json> <test1.md> [test2.md ...]
```

**Example (Data Engineer):**
```bash
python Scripts/parse_questions.py de \
    certifications/data_engineer/de_questions.json \
    raw_tests/de_test1.md raw_tests/de_test2.md raw_tests/de_test3.md
```

**With domain auto-classification:**
```bash
python Scripts/parse_questions.py de \
    certifications/data_engineer/de_questions.json \
    raw_tests/de_test1.md \
    --domains certifications/data_engineer/de_domains.json
```

The domain config JSON looks like:
```json
{
  "Domain 1: Data Movement": {
    "weight": "28%",
    "keywords": ["copy into", "stage", "snowpipe", "stream", "task"]
  },
  "Domain 2: Performance Optimization": {
    "weight": "19%",
    "keywords": ["warehouse", "cache", "clustering", "pruning"]
  }
}
```

### After Parsing -- Quality Check

The parser prints validation stats. Look for:
- Questions with < 3 options (parsing failure -- remove or fix)
- Questions with no correct answer (remove)
- Untagged domain questions (manually assign or improve keywords)

---

## Step 2: Create the Folder Structure

```
certifications/
  <category>/                          # e.g., sfc-gh-sd-specialist
    <cert_folder>/                     # e.g., sfc-gh-sd-gen_ai
      <exam_code>/                     # e.g., ges_c01
        <cert>_questions.json          # parsed questions (from Step 1)
        domain_01_<name>/
          review_notes_en.md           # English review notes
          review_notes_pt.md           # Portuguese (optional)
          review_notes_es.md           # Spanish (optional)
        domain_02_<name>/
          review_notes_en.md
          ...
```

**Categories:**
- `sfc-gh-sd-core` -- Core certification
- `sfc-gh-sd-advanced` -- Advanced certs (Architect, Data Engineer)
- `sfc-gh-sd-specialist` -- Specialist certs (Gen AI, etc.)

---

## Step 3: Add to registry.json

Open `registry.json` and add a new entry inside `"certifications"`. Use an existing cert as a template.

**Required fields:**

```json
"your_cert_key": {
  "name": "Display Name",
  "code": "EXAM-CODE",
  "full_name": "SnowPro Full Name (CODE)",
  "category": "specialist",
  "icon": "",
  "color": "#HEX_COLOR",
  "sidebar_gradient": "linear-gradient(135deg,#COLOR1,#COLOR2)",
  "sidebar_accent": "#LIGHT_HEX",
  "sidebar_text": "#LIGHTEST_HEX",
  "sidebar_sub": "#MED_HEX",
  "difficulty": "specialist",
  "available": true,
  "exam": {
    "questions": 65,
    "time": "115 min",
    "cost": "$175",
    "pass_score": "750/1000"
  },
  "info": {
    "en": "65 Qs | 115 min | $175 | Prereq: Core",
    "pt": "65 Qs | 115 min | $175 | Pre-req: Core",
    "es": "65 Qs | 115 min | $175 | Prereq: Core"
  },
  "questions_file": "certifications/<category>/<folder>/<exam>/questions.json",
  "domains": {
    "Domain 1: Name Here": {
      "dir": "certifications/<category>/<folder>/<exam>/domain_01_name",
      "color": "#HEX",
      "css_num": "1",
      "emoji": "",
      "weight": "30%"
    }
  },
  "domain_tips": {
    "Domain 1: Name Here": [
      "Tip 1: Key concept to remember.",
      "Tip 2: Another important point."
    ]
  }
}
```

**Important:**
- `available: true` makes it show in the app immediately
- `available: false` shows it as "Coming Soon"
- Domain names in `domains` must EXACTLY match the `domain` field in your questions JSON
- `questions_file` path is relative to the project root

---

## Step 4: Write Review Notes

Each domain needs at least `review_notes_en.md`. Format:

```markdown
# Domain 1: Your Domain Name

## 1.1 Topic Name

Key concept explanation here.

> **Exam Trap:** Watch out for this common mistake...

### ELI5
Simple explanation as if explaining to a 5-year-old.

### Real-World Example
Practical scenario showing when you'd use this.

---

## 1.2 Next Topic
...
```

For translations, create `review_notes_pt.md` and `review_notes_es.md` in the same folder.

---

## Step 5: Verify

1. **Run the app:** `streamlit run app.py`
2. **Check the sidebar:** Your cert should appear in the dropdown
3. **Test quiz:** Start a practice quiz -- verify questions load, answers work
4. **Test review notes:** Navigate to review notes -- verify content renders
5. **Check domains:** Domain filter in quiz should show your domains

---

## Adding Questions to an Existing Cert

Use `--append` to add new test files to an existing questions JSON:

```bash
python Scripts/parse_questions.py genai \
    certifications/.../gen_ai_questions.json \
    new_test_file.md \
    --append
```

This preserves existing questions and adds the new ones.

---

## Question JSON Schema Reference

Each question object:

```json
{
  "id": "genai_test1_q1",
  "source": "genai_test1",
  "question_num": 1,
  "question": "The question text...",
  "options": [
    {"text": "A. Option text", "explanation": ""},
    {"text": "B. Option text", "explanation": ""}
  ],
  "correct_indices": [2],
  "multi_select": false,
  "multi_select_count": 1,
  "overall_explanation": "Detailed explanation...",
  "domain_raw": "",
  "domain": "Domain 1: Your Domain Name",
  "archived": false
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (cert_source_qN) |
| `source` | Yes | Source test name |
| `question` | Yes | Question text |
| `options` | Yes | Array of {text, explanation} objects |
| `correct_indices` | Yes | 0-based indices of correct options |
| `multi_select` | Yes | true if multiple correct answers |
| `overall_explanation` | Yes | Explanation shown after answering |
| `domain` | Yes | Must match a domain key in registry.json |
| `archived` | No | Set true to hide without deleting |
