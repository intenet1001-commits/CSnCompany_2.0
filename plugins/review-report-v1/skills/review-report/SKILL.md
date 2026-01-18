---
name: review-report
description: This skill should be used when user asks "/review", "검토 보고서", "검토보고", "분석 보고서", "review report", "analysis report", "법률 검토", "규제 검토", "라이선스 검토", or wants to create professional Korean review/analysis documents for financial institutions.
---

# Professional Korean Review Report Writer

> 금융기관 검토/분석 보고서 작성 템플릿

## Purpose

Create professional Korean review and analysis reports with:
- Checkbox section markers (□)
- Hyphen bullet points (-)
- Circled number sequences (①②③)
- Reference/note boxes with borders
- Structured tables

## CRITICAL RULES - MUST FOLLOW

### 1. Font Requirements (필수)

```python
from docx.shared import Pt, Cm
from docx.oxml.ns import qn

def set_font(run, font_name='나눔명조', size=11, bold=False):
    run.font.name = font_name
    run.font.size = Pt(size)
    run.font.bold = bold
    run._element.rPr.rFonts.set(qn('w:eastAsia'), font_name)
```

### 2. NO EMOJI - NEVER USE

**절대 이모지 사용 금지. 다음 문자만 사용:**
- 섹션 마커: `□` (U+25A1, 빈 체크박스)
- 불릿: `-` (하이픈)
- 원숫자: `①` `②` `③` `④` `⑤` (U+2460~)
- 참고: `*`
- 주석: `o` (소문자 o)

**금지 기호:** ❗ ✓ ✅ ❌ 📌 🔹 → ➡ 등 모든 이모지

### 3. Spacing Rules

**space_after는 항상 0pt. space_before는 섹션만 12pt.**

---

## Document Structure

### Page Setup (2.54cm margins)

```python
from docx import Document
from docx.shared import Cm

doc = Document()
for section in doc.sections:
    section.top_margin = Cm(2.54)
    section.bottom_margin = Cm(2.54)
    section.left_margin = Cm(2.54)
    section.right_margin = Cm(2.54)
```

---

## Document Header

### Title (제목)

```python
def add_title(doc, title_text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run(title_text)
    set_font(run, size=16, bold=True)
```

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | **16pt** |
| Style | Bold |
| Alignment | Center |
| Underline | Optional (제목에 밑줄 가능) |

### Department and Date (부서/날짜)

```python
def add_department_date(doc, dept, date):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = p.add_run(f'{dept} {date}')
    set_font(run, size=11, bold=False)
```

| Item | Value |
|------|-------|
| Format | `부서명 YYYY.MM.DD` |
| Font | 나눔명조 |
| Size | **11pt** |
| Alignment | Right |

---

## Hierarchy Levels

### Level 1: Checkbox Section (체크박스 섹션) - □

```python
def add_checkbox_section(doc, title):
    # 빈 줄 추가 (섹션 간 구분)
    doc.add_paragraph()

    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.space_before = Pt(12)
    pf.space_after = Pt(0)
    pf.left_indent = Cm(0)

    run = p.add_run(f'□ {title}')
    set_font(run, size=12, bold=True)
```

| Item | Value |
|------|-------|
| Symbol | **□** (U+25A1, 빈 체크박스) |
| Font | 나눔명조 |
| Size | **12pt** |
| Style | **Bold** |
| Left Indent | **0cm** |
| Space Before | **12pt** |
| Space After | **0pt** |

### Level 2: Hyphen Bullet (하이픈 불릿) - -

```python
def add_hyphen_item(doc, content, bold_keyword=None):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(0.5)
    pf.first_line_indent = Cm(-0.3)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    run_hyphen = p.add_run('- ')
    set_font(run_hyphen, size=11, bold=False)

    if bold_keyword and content.startswith(bold_keyword):
        run_kw = p.add_run(bold_keyword)
        set_font(run_kw, size=11, bold=True)
        run_rest = p.add_run(content[len(bold_keyword):])
        set_font(run_rest, size=11, bold=False)
    else:
        run_content = p.add_run(content)
        set_font(run_content, size=11, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **-** (하이픈) |
| Font | 나눔명조 |
| Size | **11pt** |
| Left Indent | **0.5cm** |
| Hanging Indent | **-0.3cm** |
| Space Before | **0pt** |
| Space After | **0pt** |

### Level 3: Circled Number (원숫자) - ①②③

```python
CIRCLED_NUMBERS = ['①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨', '⑩']

def add_circled_number_item(doc, number, content):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(0.5)
    pf.first_line_indent = Cm(-0.5)
    pf.space_before = Pt(6)
    pf.space_after = Pt(0)

    # 원숫자 + 제목 (굵게)
    run_num = p.add_run(f'{CIRCLED_NUMBERS[number-1]} ')
    set_font(run_num, size=11, bold=True)

    run_content = p.add_run(content)
    set_font(run_content, size=11, bold=True)
```

| Item | Value |
|------|-------|
| Symbol | **①②③④⑤** (U+2460~U+2469) |
| Font | 나눔명조 |
| Size | **11pt** |
| Style | **Bold** |
| Left Indent | **0.5cm** |
| Hanging Indent | **-0.5cm** |
| Space Before | **6pt** |
| Space After | **0pt** |

### Level 4: Sub-hyphen (서브 하이픈) - -

```python
def add_sub_hyphen_item(doc, content):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(1.0)
    pf.first_line_indent = Cm(-0.3)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    run = p.add_run(f'- {content}')
    set_font(run, size=11, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **-** (하이픈) |
| Font | 나눔명조 |
| Size | **11pt** |
| Left Indent | **1.0cm** |
| Hanging Indent | **-0.3cm** |

### Level 5: Note/Reference (참고) - *

```python
def add_note(doc, content):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(0.5)
    pf.space_before = Pt(2)
    pf.space_after = Pt(0)

    run = p.add_run(f'* {content}')
    set_font(run, size=10, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **\*** (별표) |
| Font | 나눔명조 |
| Size | **10pt** |
| Left Indent | **0.5cm** |

### Level 6: Sub-note (보조 참고) - o

```python
def add_sub_note(doc, content):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(0.8)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    run = p.add_run(f'o {content}')
    set_font(run, size=10, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **o** (소문자 o) |
| Font | 나눔명조 |
| Size | **10pt** |
| Left Indent | **0.8cm** |

---

## Reference Box (참고 박스)

검토보고서에서 자주 사용되는 테두리 있는 참고 박스입니다.

```python
from docx.oxml.ns import nsdecls
from docx.oxml import parse_xml

def add_reference_box(doc, title, items):
    """
    테두리 있는 참고 박스 추가
    items: list of strings
    """
    # 표로 구현 (1행 1열)
    table = doc.add_table(rows=1, cols=1)
    table.style = 'Table Grid'

    cell = table.rows[0].cells[0]

    # 제목
    p = cell.paragraphs[0]
    run = p.add_run(f'[{title}]')
    set_font(run, size=10, bold=True)

    # 내용
    for item in items:
        p = cell.add_paragraph()
        run = p.add_run(f'o {item}')
        set_font(run, size=10, bold=False)
```

### Reference Box Style

| Item | Value |
|------|-------|
| Border | Table Grid (검은 테두리) |
| Title | **[제목]** 형식, 10pt Bold |
| Content | o 기호, 10pt Normal |
| Background | 흰색 (기본) |

---

## Tables

### Table Title

```python
def add_table_title(doc, title):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(0)
    pf.space_before = Pt(6)

    run = p.add_run(f'[{title}]')
    set_font(run, size=11, bold=True)
```

### Table Header

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | **10pt** |
| Style | **Bold** |
| Alignment | **Center** |
| Background | **#F2F2F2** (연한 회색) |

### Table Content

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | **10pt** |
| Style | Normal |
| Alignment | Left or Center |

---

## Document Template

### Standard Review Report Structure

```
[보고서 제목]
                                    부서명 YYYY.MM.DD

□ 개요
 - 배경 설명
 - 목적 설명

□ 검토 내용
 - 주요 검토 사항 1
 - 주요 검토 사항 2
   * 참고: 부연 설명

[표 제목]
| 항목 | 내용 | 비고 |
|------|------|------|
| ... | ... | ... |

□ 검토 결과
 - 결과 1
 - 결과 2

[참고박스 제목]
o 참고 내용 1
o 참고 내용 2

□ 향후 계획
 ① 첫 번째 방향
   - 세부 내용
 ② 두 번째 방향
   - 세부 내용
```

---

## Complete Example

```python
from docx import Document
from docx.shared import Pt, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn

CIRCLED_NUMBERS = ['①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨', '⑩']

def set_font(run, font_name='나눔명조', size=11, bold=False):
    run.font.name = font_name
    run.font.size = Pt(size)
    run.font.bold = bold
    run._element.rPr.rFonts.set(qn('w:eastAsia'), font_name)

# Create document
doc = Document()

# Page setup
for section in doc.sections:
    section.top_margin = Cm(2.54)
    section.bottom_margin = Cm(2.54)
    section.left_margin = Cm(2.54)
    section.right_margin = Cm(2.54)

# Title
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run('[검토 주제] 검토의 건')
set_font(run, size=16, bold=True)

# Department and Date
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
run = p.add_run('부서명 2026.01.19')
set_font(run, size=11)

# Section 1: 개요
doc.add_paragraph()
p = doc.add_paragraph()
p.paragraph_format.space_before = Pt(12)
run = p.add_run('□ 개요')
set_font(run, size=12, bold=True)

# Hyphen items
p = doc.add_paragraph()
p.paragraph_format.left_indent = Cm(0.5)
p.paragraph_format.first_line_indent = Cm(-0.3)
run = p.add_run('- 검토 배경 설명')
set_font(run, size=11)

# Section 2: 검토 내용
doc.add_paragraph()
p = doc.add_paragraph()
p.paragraph_format.space_before = Pt(12)
run = p.add_run('□ 검토 내용')
set_font(run, size=12, bold=True)

# Section 3: 향후 계획
doc.add_paragraph()
p = doc.add_paragraph()
p.paragraph_format.space_before = Pt(12)
run = p.add_run('□ 향후 계획')
set_font(run, size=12, bold=True)

# Circled number items
p = doc.add_paragraph()
p.paragraph_format.left_indent = Cm(0.5)
p.paragraph_format.first_line_indent = Cm(-0.5)
p.paragraph_format.space_before = Pt(6)
run = p.add_run('① 첫 번째 방향')
set_font(run, size=11, bold=True)

p = doc.add_paragraph()
p.paragraph_format.left_indent = Cm(1.0)
p.paragraph_format.first_line_indent = Cm(-0.3)
run = p.add_run('- 세부 내용')
set_font(run, size=11)

doc.save('review_report.docx')
```

---

## Checklist Before Output

1. ✓ 모든 run에 `set_font()` 호출했는가? (나눔명조 설정)
2. ✓ 이모지 사용하지 않았는가?
3. ✓ 섹션 마커로 □ 사용했는가?
4. ✓ 불릿으로 - (하이픈) 사용했는가?
5. ✓ 원숫자 (①②③) 올바르게 사용했는가?
6. ✓ 참고박스가 테두리 있는 표로 구현되었는가?
7. ✓ 여백이 2.54cm인가?
8. ✓ space_after가 모두 0pt인가?

---

## Quick Reference Card

| Level | Symbol | Size | Bold | Left | Hanging |
|-------|--------|------|------|------|---------|
| Title | - | 16pt | Yes | 0 | 0 |
| Dept | - | 11pt | No | 0 | 0 |
| L1 Section | □ | 12pt | Yes | 0 | 0 |
| L2 Hyphen | - | 11pt | No | 0.5cm | -0.3cm |
| L3 Circled | ①②③ | 11pt | Yes | 0.5cm | -0.5cm |
| L4 SubHyphen | - | 11pt | No | 1.0cm | -0.3cm |
| L5 Note | * | 10pt | No | 0.5cm | 0 |
| L6 SubNote | o | 10pt | No | 0.8cm | 0 |
| RefBox Title | [제목] | 10pt | Yes | - | - |
| RefBox Content | o | 10pt | No | - | - |

---

## Differences from report-writer

| Feature | report-writer | review-report |
|---------|---------------|---------------|
| Section marker | I. II. III. (로마숫자) | □ (체크박스) |
| Primary bullet | • (dot) | - (하이픈) |
| Numbering | 1. 2. 3. | ①②③ (원숫자) |
| Reference box | Not included | Included |
| Title size | 18pt | 16pt |
| Use case | 전략/기획 보고서 | 검토/분석 보고서 |
