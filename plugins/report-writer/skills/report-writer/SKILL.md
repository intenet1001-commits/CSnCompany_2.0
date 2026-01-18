---
name: report-writer
description: This skill should be used when user asks "보고서 작성", "report writing", "문서 작성", "DOCX 생성", "business report", "전략 보고서", "기획 보고서", "한글 보고서", "Word 문서", "python-docx", or wants to create professional Korean business documents with structured formatting.
---

# Professional Korean Business Report Writer

> Universal document template for corporate strategy and planning reports

## Purpose

Create professional Korean business reports with:
- Consistent hierarchical numbering system
- Proper Korean typography (나눔명조)
- python-docx compatible formatting
- Collapsible sections in Word

## Document Structure

### Page Setup

| Item | Value |
|------|-------|
| Paper Size | Letter (8.5 x 11 inches / 21.59cm x 27.94cm) |
| Top Margin | 2.54cm |
| Bottom Margin | 2.54cm |
| Left Margin | 2.54cm |
| Right Margin | 2.54cm |
| Footer Distance | 1.0cm |

### Page Number
- Position: Footer center
- Font: 나눔명조, 10pt
- Auto page number field

## Heading Hierarchy

```
I. 대항목 (Roman numerals)
   1. 번호항목 (Arabic numbers)
      • 불릿항목 (Filled dot)
      (1) 하위번호항목 (Parenthesis numbers)
          - 하이픈 불릿항목
```

### Spacing Summary

| Level | Element | Space Before | Space After |
|-------|---------|--------------|-------------|
| 1 | Section Heading (I, II...) | 10pt | 4pt |
| 2 | Numbered Item (1. 2...) | 6pt | 2pt |
| 3 | Bullet Item (•) | 2pt | 2pt |
| 4 | Sub-numbered ((1) (2)...) | 2pt | 2pt |
| 5 | Dash Bullet (-) | 1pt | 1pt |

### Level 1: Section Heading (대항목)

```
I. 추진 배경 및 목표
II. 핵심 과제
III. 상세 실행 방안
IV. 성과 지표(KPI)
[별첨] 참고 자료
```

| Item | Value |
|------|-------|
| Symbol | Roman numerals (I, II, III...) or [별첨] |
| Font | 나눔명조 |
| Size | 14pt |
| Style | Bold |
| Alignment | Left |
| Space Before | 10pt |
| Space After | 4pt |
| Outline Level | 1 (enables collapsible in Word) |

### Level 2: Numbered Item (번호항목)

```
1. 2025년 성과 및 확대
2. 조직 강화
3. 최상위 미션
```

| Item | Value |
|------|-------|
| Symbol | Arabic number + period (1. 2. 3.) |
| Font | 나눔명조 |
| Size | 12pt |
| Number Style | Bold |
| Content Style | Normal |
| Left Indent | 0.7cm |
| Hanging Indent | -0.5cm |
| Space Before | 6pt |
| Space After | 2pt |

### Level 3: Bullet Item (불릿항목)

```
• 신규 프로젝트의 성공적 완수를 통해 검증된 역량을 바탕으로...
```

| Item | Value |
|------|-------|
| Symbol | • (filled dot) |
| Font | 나눔명조 |
| Size | 11pt |
| Left Indent | 1.0cm |
| Hanging Indent | -0.4cm |
| Space Before | 2pt |
| Space After | 2pt |
| Keyword Emphasis | `bold_keyword` parameter for leading text |

### Level 4: Sub-numbered Item (하위번호항목)

```
(1) 세부 항목 1
(2) 세부 항목 2
```

| Item | Value |
|------|-------|
| Symbol | Parenthesis numbers ((1) (2) (3)...) |
| Font | 나눔명조 |
| Size | 11pt |
| Number Style | Bold |
| Left Indent | 1.3cm |
| Hanging Indent | -0.7cm |
| Space Before | 2pt |
| Space After | 2pt |

### Level 5: Dash Bullet (하이픈 불릿)

```
- 세부 실행 내용 기술
```

| Item | Value |
|------|-------|
| Symbol | - (hyphen) |
| Font | 나눔명조 |
| Size | 11pt |
| Left Indent | 1.8cm |
| Hanging Indent | -0.4cm |
| Space Before | 1pt |
| Space After | 1pt |

## Document Header

### Title

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 18pt |
| Style | Bold |
| Alignment | Center |

### Department and Date

```
[부서명](YYYY.MM.DD)
```

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 11pt |
| Format | [부서명](YYYY.MM.DD) |
| Alignment | Right |

## Table Formatting

### Table Title

```
[전략적 지향점]
```

| Item | Value |
|------|-------|
| Format | Wrapped in brackets |
| Font | 나눔명조 |
| Size | 11pt |
| Style | Bold |
| Left Indent | 0.19cm |

### Table Header

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 10pt |
| Style | Bold |
| Alignment | Center |
| Background | #F2F2F2 (light gray) |
| Row Height | 0.64cm (fixed) |
| Line Spacing | 1.15x |

### Table Content

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 10pt |
| Style | Normal |
| Alignment | Left |
| Line Spacing | 1.15x |

## Footnotes

### Format
- Body: Superscript number `1)` format
- Page bottom: `1) Footnote content` format

### Style

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Body Superscript | 9pt |
| Bottom Footnote | 9pt (18 half-points) |

## Document End

```
[끝]
```

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 11pt |
| Style | Bold |
| Alignment | Center |

## Python-docx Function Reference

### Basic Functions

| Function | Purpose | Parameters |
|----------|---------|------------|
| `set_font()` | Set font | font_name, size, bold |
| `set_line_spacing()` | Set line spacing | multiplier (default 1.15) |

### Document Structure Functions

| Function | Purpose | Parameters |
|----------|---------|------------|
| `add_heading_text()` | Document title | size=18, bold=True, alignment |
| `add_section_heading()` | Section heading | size=14, outline_level, space_before |
| `add_numbered_item()` | Numbered item (1. 2. 3.) | number, content |
| `add_sub_numbered_item()` | Sub-number ((1) (2)) | number, content |
| `add_dot_bullet_item()` | Bullet (•) | content, bold_keyword |
| `add_dash_bullet_item()` | Hyphen (-) | content, bold_keyword |
| `add_sub_bullet()` | Sub-bullet (o) | content |
| `add_note()` | Note (*) | content, size=10 |

### Table and Footnote Functions

| Function | Purpose | Parameters |
|----------|---------|------------|
| `add_table_title()` | Table title | title |
| `create_table()` | Create table | headers, rows |
| `create_footnote()` | Add footnote | paragraph, footnote_text |
| `save_doc_with_footnotes()` | Save with footnotes | filepath |

## Template Example

```markdown
[보고서 제목]

[작성부서](YYYY.MM)

I. 추진 배경 및 목표

1. 첫 번째 주제
   • 핵심 키워드를 앞에 두고 상세 내용 기술

2. 두 번째 주제
   • 내용 기술

II. 핵심 과제

1. 과제명
   (1) 세부 과제 1
       - 상세 내용
   (2) 세부 과제 2
       - 상세 내용

III. 상세 실행 방안

[표 제목]
| 항목 | 내용 |
| --- | --- |
| 항목1 | 내용1 |

IV. 성과 지표

[끝]
```

## Emphasis Rules

- **Bold**: Section headings, numbers, table headers, key keywords
- **Normal**: Body content, explanatory text
- **Single quotes**: English terms, standard names (e.g., 'Complete Care')

## Collapsible Sections

Word 2016+ displays triangle icon on section headings for expand/collapse:

```python
def set_collapsible_heading(paragraph, outline_level=1):
    pPr = paragraph._p.get_or_add_pPr()
    outlineLvl = OxmlElement('w:outlineLvl')
    outlineLvl.set(qn('w:val'), str(outline_level - 1))
    pPr.append(outlineLvl)
```

| Level | Usage |
|-------|-------|
| 1 | Section heading (I, II, III...) |
| 2 | Sub-section (if needed) |
| 3 | Sub-sub-section (if needed) |

## Usage Examples

### Create a new report
```python
from docx import Document
from docx.shared import Pt, Cm

doc = Document()

# Set page margins
for section in doc.sections:
    section.top_margin = Cm(2.54)
    section.bottom_margin = Cm(2.54)
    section.left_margin = Cm(2.54)
    section.right_margin = Cm(2.54)

# Add title
add_heading_text(doc, '[보고서 제목]')

# Add department and date
add_department_date(doc, '[부서명]', 'YYYY.MM.DD')

# Add section
add_section_heading(doc, 'I. [섹션 제목]')

# Add numbered item
add_numbered_item(doc, 1, '[항목 내용]')

# Add bullet
add_dot_bullet_item(doc, '[키워드]: [상세 설명]...',
                    bold_keyword='[키워드]')

# Save
doc.save('report.docx')
```

## Rules

1. **Font Consistency**: Always use 나눔명조 for Korean documents
2. **Line Spacing**: Use 1.15x for all content
3. **Hierarchy**: Follow the numbering system strictly
4. **Indentation**: Each level has specific indent values
5. **Emphasis**: Use bold for keywords, not underlining or italics
6. **Tables**: Always include table title in brackets before the table
7. **Document End**: Always include [끝] at the end
