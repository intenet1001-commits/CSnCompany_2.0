---
name: report-writer
description: This skill should be used when user asks "/report", "/report-writer", "보고서 작성", "report writing", "문서 작성", "DOCX 생성", "business report", "전략 보고서", "기획 보고서", "한글 보고서", "Word 문서", "python-docx", or wants to create professional Korean business documents with structured formatting.
---

# Professional Korean Business Report Writer v2

> 증권사/금융사 전략/기획 부서 전문 보고서 작성 템플릿

## Purpose

Create professional Korean business reports with:
- 7-level hierarchical numbering system
- Proper Korean typography (나눔명조)
- python-docx compatible formatting
- Collapsible sections in Word 2016+
- Compact spacing (no excessive gaps)

---

## 1. Page Setup

### 1.1 Paper and Margins

| Item | Value |
|------|-------|
| Paper Size | Letter (8.5 × 11 inches / 21.59cm × 27.94cm) |
| Top Margin | 2.54cm |
| Bottom Margin | 2.54cm |
| Left Margin | 2.54cm |
| Right Margin | 2.54cm |
| Footer Distance | 1.0cm |

### 1.2 Page Number

- Position: Footer center
- Font: 나눔명조, 10pt
- Auto page number field

---

## 2. Document Header

### 2.1 Title

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 18pt |
| Style | Bold |
| Alignment | Center |

### 2.2 Department and Date

```
sq1(GBS)(2026.01)
```

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 11pt |
| Style | Normal |
| Alignment | Right |
| Format | 부서명(YYYY.MM) |

### 2.3 Header Spacing

- 1 empty line between title and department

---

## 3. Line Spacing

| Target | Line Spacing |
|--------|--------------|
| All body text | 1.15x |
| Table content | 1.15x |

---

## 4. Hierarchy Structure (7 Levels)

```
I. 대항목 (Roman numerals)
   1. 번호항목 (Arabic numbers)
      • 불릿항목 (Filled dot)
      (1) 하위번호항목 (Parenthesis numbers)
          - 하이픈 불릿
          o 소항목 불릿
* 참고사항
```

### Spacing Summary (Compact)

| Level | Element | Space Before | Space After | Font Size |
|-------|---------|--------------|-------------|-----------|
| 1 | Section Heading (I, II...) | 12pt | 4pt | 14pt |
| 2 | Numbered Item (1. 2...) | 4pt | 2pt | 12pt |
| 3 | Bullet Item (•) | 2pt | 1pt | 11pt |
| 4 | Sub-numbered ((1) (2)...) | 2pt | 1pt | 11pt |
| 5 | Dash Bullet (-) | 1pt | 1pt | 11pt |
| 6 | Sub-bullet (o) | 1pt | 1pt | 11pt |
| 7 | Note (*) | 4pt | 2pt | 10pt |

---

## 5. Level Details

### Level 1: Section Heading (대항목)

```
I. 추진 배경 및 목표
II. 핵심 과제
III. 상세 실행 방안
IV. 전략적 도약 및 성과 지표(KPI)
[별첨] 법인대상 세미나 운영 방안
```

| Item | Value |
|------|-------|
| Symbol | Roman numerals (I, II, III...) or [별첨] |
| Font | 나눔명조 |
| Size | 14pt |
| Style | Bold |
| Alignment | Left |
| Space Before | 12pt (별첨은 0pt) |
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
| Space Before | 4pt |
| Space After | 2pt |

### Level 3: Bullet Item (불릿항목 •)

```
• 패밀리오피스 지원의 성공적 완수를 통해 검증된 역량을 바탕으로...
```

| Item | Value |
|------|-------|
| Symbol | • (filled dot) |
| Font | 나눔명조 |
| Size | 11pt |
| Left Indent | 1.0cm |
| Hanging Indent | -0.4cm |
| Space Before | 2pt |
| Space After | 1pt |
| Keyword Emphasis | `bold_keyword` parameter |

### Level 4: Sub-numbered Item (하위번호항목)

```
(1) 6대 타겟 분류
(2) 맞춤형 솔루션
```

| Item | Value |
|------|-------|
| Symbol | Parenthesis numbers ((1) (2) (3)...) |
| Font | 나눔명조 |
| Size | 11pt |
| Number Style | Bold |
| Content Style | Normal |
| Left Indent | 1.3cm |
| Hanging Indent | -0.7cm |
| Space Before | 2pt |
| Space After | 1pt |

### Level 5: Dash Bullet (하이픈 불릿)

```
- 상장기업, 외감법인, 일반법인별로 차별화된 제안서 배포
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
| Keyword Emphasis | `bold_keyword` parameter |

### Level 6: Sub-bullet (소항목 불릿)

```
o 내용
```

| Item | Value |
|------|-------|
| Symbol | o (lowercase o) |
| Font | 나눔명조 |
| Size | 11pt |
| Left Indent | 1.5cm |
| Space Before | 1pt |
| Space After | 1pt |

### Level 7: Note (참고사항)

```
* 참고사항 내용
```

| Item | Value |
|------|-------|
| Symbol | * (asterisk) |
| Font | 나눔명조 |
| Size | 10pt |
| Left Indent | 0.19cm |
| Space Before | 4pt |
| Space After | 2pt |

---

## 6. Text Emphasis (Bold Keyword)

### 6.1 Usage

```
• 패밀리오피스 지원의 성공적 완수를 통해 검증된 역량을 바탕으로...
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (Bold)
```

### 6.2 Python Code

```python
add_dot_bullet_item(doc, '전체 내용', bold_keyword='굵게 처리할 앞부분')
add_dash_bullet_item(doc, '전체 내용', bold_keyword='굵게 처리할 앞부분')
```

### 6.3 Emphasis Rules

- **Bold**: Section headings, numbers, table headers, key keywords
- **Normal**: Body content, explanatory text
- **Single quotes**: English terms (e.g., 'Complete Care')

---

## 7. Footnotes

### 7.1 Format

- Body: Superscript number `1)` format
- Page bottom: `1) Footnote content` format

### 7.2 Python Code

```python
p = doc.add_paragraph()
run = p.add_run('단체(협회)')
set_font(run, size=11, bold=True)
create_footnote(doc, p, '단체(협회): 산업통상자원부 산하 사단법인...')
run = p.add_run('를 대상으로 먼저 시행')
set_font(run, size=11)
```

### 7.3 Footnote Style

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Body Superscript | 9pt |
| Bottom Footnote | 9pt (18 half-points) |

---

## 8. Tables

### 8.1 Table Title

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
| Position | Immediately above table |

### 8.2 Table Header

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 10pt |
| Style | Bold |
| Alignment | Center |
| Background | #F2F2F2 (light gray) |
| Row Height | 0.64cm (fixed) |
| Line Spacing | 1.15x |

### 8.3 Table Content

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 10pt |
| Style | Normal |
| Alignment | Left |
| Line Spacing | 1.15x |

### 8.4 Table Style

- Border: Table Grid (default grid)

---

## 9. Collapsible Sections

Word 2016+ displays triangle icon on section headings for expand/collapse.

### Python Code

```python
def set_collapsible_heading(paragraph, outline_level=1):
    pPr = paragraph._p.get_or_add_pPr()
    outlineLvl = OxmlElement('w:outlineLvl')
    outlineLvl.set(qn('w:val'), str(outline_level - 1))
    pPr.append(outlineLvl)
```

### Outline Levels

| Level | Usage |
|-------|-------|
| 1 | Section heading (I, II, III...) |
| 2 | Sub-section (if needed) |
| 3 | Sub-sub-section (if needed) |

---

## 10. Document End

```
[끝]
```

| Item | Value |
|------|-------|
| Font | 나눔명조 |
| Size | 11pt |
| Style | Bold |
| Alignment | Center |

---

## 11. Python-docx Function Reference

### Basic Functions

| Function | Purpose | Parameters |
|----------|---------|------------|
| `set_font()` | Set font | font_name, size, bold |
| `set_line_spacing()` | Set line spacing | multiplier (default 1.15) |

### Document Structure Functions

| Function | Purpose | Parameters |
|----------|---------|------------|
| `add_heading_text()` | Document title | size=18, bold=True, alignment |
| `add_section_heading()` | Section heading (I, II) | size=14, outline_level, space_before |
| `add_numbered_item()` | Numbered item (1. 2.) | number, content |
| `add_dot_bullet_item()` | Bullet (•) | content, bold_keyword |
| `add_sub_numbered_item()` | Sub-number ((1) (2)) | number, content |
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

---

## 12. Template Example

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
       o 추가 세부사항
   (2) 세부 과제 2
       - 상세 내용

III. 상세 실행 방안

[표 제목]
| 항목 | 내용 |
| --- | --- |
| 항목1 | 내용1 |

* 참고: 추가 설명이 필요한 경우

IV. 성과 지표

[끝]
```

---

## 13. v1 vs v2 Differences

| Item | v1 | v2 |
|------|----|----|
| Hierarchy Levels | 5 | 7 (added o, *) |
| Section Spacing | 10pt | 12pt |
| Item Spacing | 6pt/2pt | 4pt/2pt (compact) |
| Sub-bullet (o) | Not supported | Supported |
| Note (*) | Not supported | Supported |
| Base Template | Custom | 보고서_템플릿_가이드_v4.md |

---

## Rules

1. **Font Consistency**: Always use 나눔명조 for Korean documents
2. **Line Spacing**: Use 1.15x for all content
3. **Hierarchy**: Follow the 7-level numbering system strictly
4. **Indentation**: Each level has specific indent values
5. **Emphasis**: Use bold for keywords, not underlining or italics
6. **Tables**: Always include table title in brackets before the table
7. **Document End**: Always include [끝] at the end
8. **Compact Spacing**: Avoid excessive empty lines between items
