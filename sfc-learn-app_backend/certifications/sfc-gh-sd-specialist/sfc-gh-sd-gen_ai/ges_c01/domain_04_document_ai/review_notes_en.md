# Domain 4: Snowflake Document AI

> **Note:** As of March 2026, Document AI has been removed from the GES-C01 exam scope. This content is kept for reference and general knowledge.

---

## 4.1 WHAT IS DOCUMENT AI

### Key Concepts

- **Document AI** is a Snowflake-native service for extracting structured data from unstructured documents (PDFs, images, scanned forms)
- Built on top of large language models -- no ML expertise required
- Workflow: upload documents to a stage -> create a Document AI model -> define extraction fields -> run predictions -> get structured output in a table
- Supports: invoices, receipts, contracts, tax forms, medical records, any semi-structured document

**Core objects:**

| Object | Purpose |
|---|---|
| `DOCUMENT AI BUILD` | Creates a model from example documents + defined fields |
| `DOCUMENT AI PREDICT` | Runs extraction on new documents using a trained model |
| Stage | Where source documents (PDFs/images) are stored |
| Output table | Where extracted structured data lands |

### How It Works

1. **Upload** example documents to a Snowflake stage
2. **Create** a Document AI model: define the fields you want to extract (e.g., "invoice_number", "total_amount", "vendor_name")
3. **Label** a few examples (optional -- zero-shot works for common document types)
4. **Build** the model -- Snowflake trains/fine-tunes the extraction model
5. **Predict** -- run the model on new documents to extract structured data

### Why This Matters

A finance team receives 10,000 vendor invoices per month as PDFs. Instead of manual data entry or custom OCR pipelines, Document AI extracts invoice number, date, line items, and totals directly into a Snowflake table -- queryable via SQL.

### Best Practices

- Start with zero-shot extraction (no labeling) -- it works well for standard document types
- Label 10-20 examples for custom or unusual document formats
- Store source documents in organized stage paths (e.g., `@docs/invoices/2025/`)
- Validate extraction accuracy on a sample before running at scale
- Combine with Snowpipe for automated document ingestion pipelines

---

## 4.2 EXTRACTION AND PREDICTIONS

### Key Concepts

- **Zero-shot extraction:** Define field names and descriptions, and the model extracts values without any labeled examples. Works best for standard document types (invoices, receipts, W-2s)
- **Few-shot extraction:** Label 10-20 examples to improve accuracy on custom layouts
- **Prediction output:** Returns structured data with confidence scores per field
- **Batch processing:** Run predictions on thousands of documents in parallel using Snowflake compute

**Supported document types:**

- PDF (text-based and scanned/image-based)
- PNG, JPEG, TIFF images
- Multi-page documents (each page processed)

### Common Extraction Fields

| Document Type | Typical Fields |
|---|---|
| Invoice | invoice_number, date, vendor, line_items, total, tax |
| Receipt | merchant, date, items, subtotal, tax, total |
| Contract | parties, effective_date, term, payment_terms |
| Tax form (W-2) | employer, employee, wages, federal_tax_withheld |

### Why This Matters

An insurance company needs to extract claim details from scanned medical forms. Traditional OCR requires custom templates per form layout. Document AI uses LLMs to understand the document semantically -- it works across different layouts without per-template configuration.

---

## 4.3 GOVERNANCE AND SECURITY

### Key Concepts

- Documents stay within the Snowflake security boundary -- no data leaves Snowflake
- Access control: standard Snowflake RBAC applies to Document AI models and output tables
- Sensitive document handling: combine with masking policies on extracted fields (e.g., mask SSN after extraction)
- Audit: extraction operations logged in QUERY_HISTORY like any other Snowflake operation
- Cost: Document AI uses serverless compute -- billed per document processed

### Best Practices

- Apply masking policies to extracted PII fields (SSN, account numbers)
- Use separate roles for document upload vs. extraction vs. result access
- Monitor costs via ACCOUNT_USAGE views
- Retain source documents in stages with appropriate lifecycle policies

---

## CONFUSING PAIRS -- Document AI

| They ask about... | The answer is... | NOT... |
|---|---|---|
| **Document AI** vs **PARSE_DOCUMENT** | **Document AI** = model-based extraction with custom fields, training | **PARSE_DOCUMENT** = simpler function-based text/layout extraction, no training needed |
| **Zero-shot** vs **few-shot** | **Zero-shot** = no examples needed, works for standard docs | **Few-shot** = 10-20 labeled examples for custom layouts |
| **Document AI** vs **external OCR** | **Document AI** = native Snowflake, data stays in boundary | **External OCR** = data leaves Snowflake, requires API integration |
| **Stage** vs **output table** | **Stage** = where source PDFs/images live | **Output table** = where extracted structured data lands |

---

## FLASHCARDS -- Domain 4

**Q1:** What is Document AI?
**A1:** A Snowflake-native service that extracts structured data from unstructured documents (PDFs, images) using LLMs.

**Q2:** Does Document AI require ML expertise?
**A2:** No. You define fields to extract, optionally label a few examples, and Snowflake handles the model.

**Q3:** What is zero-shot extraction?
**A3:** Extracting data without any labeled examples -- the model uses field names and descriptions to understand what to extract.

**Q4:** Where are source documents stored?
**A4:** In Snowflake stages (internal or external).

**Q5:** Does data leave Snowflake during Document AI processing?
**A5:** No. Documents are processed within the Snowflake security boundary.

**Q6:** How is Document AI billed?
**A6:** Serverless compute -- billed per document processed.

**Q7:** What document formats does Document AI support?
**A7:** PDF (text and scanned), PNG, JPEG, TIFF.

**Q8:** How do you handle PII in extracted data?
**A8:** Apply Snowflake masking policies to the extracted output columns (e.g., mask SSN, account numbers).

**Q9:** Is Document AI still on the GES-C01 exam?
**A9:** No. It was removed from the exam scope as of March 2026.

**Q10:** What is the difference between Document AI and PARSE_DOCUMENT?
**A10:** Document AI uses model-based extraction with custom fields and optional training. PARSE_DOCUMENT is a simpler function for text/layout extraction without training.
