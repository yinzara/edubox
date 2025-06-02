# Legal Documents PDF Generation

This directory contains tools to convert the legal Markdown documents to PDF format.

## ✅ All PDFs Successfully Generated!

All 10 legal documents have been converted to PDF format and are available in the `legal/pdf/` directory:

1. Articles of Incorporation (139K)
2. Board Member Agreement (153K)
3. Corporate Bylaws (160K)
4. Conflict of Interest Policy (142K)
5. EIN Application Guide (165K)
6. Financial Policies and Procedures (208K)
7. Form 1023 Eligibility Worksheet (169K)
8. Initial Board Resolution (143K)
9. Mission, Vision, and Values (168K)
10. Nonprofit Formation Status (198K)

## PDF Generation Scripts

We have several scripts for different scenarios:

### 1. **generate-legal-pdfs-unicode.sh** (Recommended)
- Uses XeLaTeX for full Unicode support (handles emojis)
- Falls back to pdflatex with emoji removal if needed
- Works with BasicTeX installation
- **Usage**: `./generate-legal-pdfs-unicode.sh [filename]`

### 2. **generate-legal-pdfs-basictex.sh**
- Specifically configured for BasicTeX
- Adds `/Library/TeX/texbin` to PATH
- Handles most documents well
- **Usage**: `./generate-legal-pdfs-basictex.sh [filename]`

### 3. **generate-legal-pdfs-html.sh**
- Creates HTML files that can be printed to PDF
- Works without any LaTeX installation
- **Usage**: `./generate-legal-pdfs-html.sh [filename]`

### 4. **generate-legal-pdfs.sh** & **generate-legal-pdfs-simple.sh**
- Original scripts requiring full LaTeX installation
- Kept for compatibility

## Requirements

- **Pandoc**: Document converter (required for all scripts)
- **BasicTeX or MacTeX**: For direct PDF generation
  - BasicTeX (smaller): `brew install --cask basictex`
  - MacTeX (full): `brew install --cask mactex`

## Usage

### Convert All Documents
```bash
./generate-legal-pdfs-unicode.sh
```

### Convert Single Document
```bash
./generate-legal-pdfs-unicode.sh bylaws
```

### View All PDFs
```bash
open legal/pdf/
```

### View Specific PDF
```bash
open legal/pdf/articles-of-incorporation.pdf
```

## Notes

- PDFs are excluded from Git via .gitignore
- All documents use professional legal formatting
- Documents include table of contents where appropriate
- Review all documents before official use
- Consider having a lawyer review before filing

## Troubleshooting

### "pdflatex not found"
- Restart your terminal after installing BasicTeX
- Or add to PATH: `export PATH="/Library/TeX/texbin:$PATH"`

### Unicode/Emoji Errors
- Use the `generate-legal-pdfs-unicode.sh` script
- It automatically handles emojis using XeLaTeX

### Failed Conversions
- Check for special characters in the markdown
- Try the HTML generation method as a fallback
