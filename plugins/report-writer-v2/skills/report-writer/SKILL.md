---
name: report-writer
description: This skill should be used when user asks "/report", "/report-writer", "보고서 작성", "report writing", "문서 작성", "DOCX 생성", "business report", "전략 보고서", "기획 보고서", "한글 보고서", "Word 문서", "python-docx", or wants to create professional Korean business documents with structured formatting.
---

# Professional Korean Business Report Writer v2

> 증권사/금융사 전략/기획 부서 전문 보고서 작성 템플릿

## CRITICAL RULES - MUST FOLLOW

### 1. Font Requirements (필수)

**모든 텍스트에 나눔명조 폰트를 명시적으로 설정해야 합니다.**

```python
from docx.shared import Pt, Cm
from docx.oxml.ns import qn

def set_font(run, font_name='나눔명조', size=11, bold=False):
    run.font.name = font_name
    run.font.size = Pt(size)
    run.font.bold = bold
    # 한글 폰트 설정 필수
    run._element.rPr.rFonts.set(qn('w:eastAsia'), font_name)
```

### 2. NO EMOJI - NEVER USE

**절대 이모지 사용 금지. 다음 문자만 사용:**
- 섹션: `I.` `II.` `III.` `IV.` (로마숫자)
- 번호: `1.` `2.` `3.` (아라비아숫자)
- 불릿: `•` (속이 찬 dot, U+2022)
- 하위번호: `(1)` `(2)` `(3)`
- 하이픈: `-`
- 소불릿: `o` (소문자 o)
- 참고: `*`

**금지 기호:** ❗ ✓ ✅ ❌ 📌 🔹 → ➡ 등 모든 이모지

### 3. Indentation MUST BE Applied

**들여쓰기와 내어쓰기 필수 적용:**

```python
from docx.shared import Cm

def set_indent(paragraph, left_cm, hanging_cm=0):
    pf = paragraph.paragraph_format
    pf.left_indent = Cm(left_cm)
    if hanging_cm:
        pf.first_line_indent = Cm(hanging_cm)  # 음수값으로 내어쓰기
```

### 4. Spacing Rules

**space_after는 항상 0pt. space_before는 섹션 헤더만 12pt.**

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

### Document Title (제목)

```python
def add_title(doc, title_text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run(title_text)
    set_font(run, size=18, bold=True)
    # space_before, space_after 모두 0
```

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | **18pt** |
| Style | Bold |
| Alignment | Center |
| Space Before | 0pt |
| Space After | 0pt |

### Department and Date (부서/날짜)

```python
def add_department_date(doc, dept, date):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = p.add_run(f'{dept}({date})')
    set_font(run, size=11, bold=False)
```

| Item | Value |
|------|-------|
| Format | `부서명(YYYY.MM)` |
| Font | 나눔명조 |
| Size | **11pt** |
| Alignment | Right |

---

## Hierarchy Levels (7 Levels)

### Level 1: Section Heading (대항목) - I. II. III.

```python
def add_section_heading(doc, text):
    # 빈 줄 추가 (섹션 간 구분)
    doc.add_paragraph()

    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.space_before = Pt(12)
    pf.space_after = Pt(0)
    pf.left_indent = Cm(0)

    run = p.add_run(text)  # 예: "I. 추진 배경"
    set_font(run, size=14, bold=True)

    # Collapsible heading 설정
    set_collapsible_heading(p, outline_level=1)
```

| Item | Value |
|------|-------|
| Symbol | **I. II. III. IV.** (로마숫자) 또는 [별첨] |
| Font | 나눔명조 |
| Size | **14pt** |
| Style | **Bold** |
| Left Indent | **0cm** |
| Space Before | **12pt** |
| Space After | **0pt** |

### Level 2: Numbered Item (번호항목) - 1. 2. 3.

```python
def add_numbered_item(doc, number, content):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(0.7)
    pf.first_line_indent = Cm(-0.5)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    # 번호 (굵게)
    run_num = p.add_run(f'{number}. ')
    set_font(run_num, size=12, bold=True)

    # 내용 (일반)
    run_content = p.add_run(content)
    set_font(run_content, size=12, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **1. 2. 3.** (아라비아숫자 + 마침표) |
| Font | 나눔명조 |
| Size | **12pt** |
| Number Style | **Bold** |
| Content Style | Normal |
| Left Indent | **0.7cm** |
| Hanging Indent | **-0.5cm** |
| Space Before | **0pt** |
| Space After | **0pt** |

### Level 3: Bullet Item (불릿항목) - •

```python
def add_bullet_item(doc, content, bold_keyword=None):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(1.0)
    pf.first_line_indent = Cm(-0.4)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    # 불릿 기호
    run_bullet = p.add_run('• ')
    set_font(run_bullet, size=11, bold=False)

    if bold_keyword and content.startswith(bold_keyword):
        # 키워드 굵게
        run_kw = p.add_run(bold_keyword)
        set_font(run_kw, size=11, bold=True)
        # 나머지 일반
        run_rest = p.add_run(content[len(bold_keyword):])
        set_font(run_rest, size=11, bold=False)
    else:
        run_content = p.add_run(content)
        set_font(run_content, size=11, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **•** (U+2022, 속이 찬 dot) |
| Font | 나눔명조 |
| Size | **11pt** |
| Left Indent | **1.0cm** |
| Hanging Indent | **-0.4cm** |
| Space Before | **0pt** |
| Space After | **0pt** |

### Level 4: Sub-numbered Item (하위번호) - (1) (2)

```python
def add_sub_numbered_item(doc, number, content):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(1.3)
    pf.first_line_indent = Cm(-0.7)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    # 번호 (굵게)
    run_num = p.add_run(f'({number}) ')
    set_font(run_num, size=11, bold=True)

    # 내용 (일반)
    run_content = p.add_run(content)
    set_font(run_content, size=11, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **(1) (2) (3)** |
| Font | 나눔명조 |
| Size | **11pt** |
| Number Style | **Bold** |
| Left Indent | **1.3cm** |
| Hanging Indent | **-0.7cm** |
| Space Before | **0pt** |
| Space After | **0pt** |

### Level 5: Dash Bullet (하이픈) - -

```python
def add_dash_item(doc, content, bold_keyword=None):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(1.8)
    pf.first_line_indent = Cm(-0.4)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    run_dash = p.add_run('- ')
    set_font(run_dash, size=11, bold=False)

    # bold_keyword 처리 (Level 3과 동일)
    run_content = p.add_run(content)
    set_font(run_content, size=11, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **-** (하이픈) |
| Font | 나눔명조 |
| Size | **11pt** |
| Left Indent | **1.8cm** |
| Hanging Indent | **-0.4cm** |
| Space Before | **0pt** |
| Space After | **0pt** |

### Level 6: Sub-bullet (소불릿) - o

```python
def add_sub_bullet(doc, content):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(1.5)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    run = p.add_run(f'o {content}')
    set_font(run, size=11, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **o** (소문자 o) |
| Font | 나눔명조 |
| Size | **11pt** |
| Left Indent | **1.5cm** |

### Level 7: Note (참고사항) - *

```python
def add_note(doc, content):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(0.19)
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)

    run = p.add_run(f'* {content}')
    set_font(run, size=10, bold=False)
```

| Item | Value |
|------|-------|
| Symbol | **\*** (별표) |
| Font | 나눔명조 |
| Size | **10pt** |
| Left Indent | **0.19cm** |

---

## Tables

### Table Title

```python
def add_table_title(doc, title):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Cm(0.19)

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
| Background | **#F2F2F2** |
| Row Height | **0.64cm** |

### Table Content

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | **10pt** |
| Style | Normal |
| Alignment | Left |

---

## Document End

```python
def add_end_mark(doc):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run('[끝]')
    set_font(run, size=11, bold=True)
```

---

## Complete Example

```python
from docx import Document
from docx.shared import Pt, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn

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
run = p.add_run('보고서 제목')
set_font(run, size=18, bold=True)

# Department
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
run = p.add_run('부서명(2026.01)')
set_font(run, size=11)

# Section I
doc.add_paragraph()  # 빈 줄
p = doc.add_paragraph()
p.paragraph_format.space_before = Pt(12)
run = p.add_run('I. 추진 배경')
set_font(run, size=14, bold=True)

# Numbered item
p = doc.add_paragraph()
p.paragraph_format.left_indent = Cm(0.7)
p.paragraph_format.first_line_indent = Cm(-0.5)
run = p.add_run('1. ')
set_font(run, size=12, bold=True)
run = p.add_run('항목 내용')
set_font(run, size=12)

# Bullet item
p = doc.add_paragraph()
p.paragraph_format.left_indent = Cm(1.0)
p.paragraph_format.first_line_indent = Cm(-0.4)
run = p.add_run('• 불릿 내용')
set_font(run, size=11)

# End
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run('[끝]')
set_font(run, size=11, bold=True)

doc.save('report.docx')
```

---

## Checklist Before Output

1. ✓ 모든 run에 `set_font()` 호출했는가? (나눔명조 설정)
2. ✓ 이모지 사용하지 않았는가?
3. ✓ 섹션 헤더에 로마숫자 (I. II. III.) 사용했는가?
4. ✓ 들여쓰기와 내어쓰기 값이 정확한가?
5. ✓ space_after가 모두 0pt인가?
6. ✓ space_before는 섹션 헤더만 12pt인가?
7. ✓ 여백이 2.54cm인가?
8. ✓ [끝] 마크를 추가했는가?

---

## Quick Reference Card

| Level | Symbol | Size | Bold | Left | Hanging | SpaceBefore |
|-------|--------|------|------|------|---------|-------------|
| Title | - | 18pt | Yes | 0 | 0 | 0 |
| Dept | - | 11pt | No | 0 | 0 | 0 |
| L1 Section | I. II. | 14pt | Yes | 0 | 0 | 12pt |
| L2 Number | 1. 2. | 12pt | Num | 0.7cm | -0.5cm | 0 |
| L3 Bullet | • | 11pt | No | 1.0cm | -0.4cm | 0 |
| L4 SubNum | (1) (2) | 11pt | Num | 1.3cm | -0.7cm | 0 |
| L5 Dash | - | 11pt | No | 1.8cm | -0.4cm | 0 |
| L6 SubBullet | o | 11pt | No | 1.5cm | 0 | 0 |
| L7 Note | * | 10pt | No | 0.19cm | 0 | 0 |
| End | [끝] | 11pt | Yes | 0 | 0 | 0 |
