# Legal Documents PDF Generation

This directory contains tools to convert the legal Markdown documents to PDF format.

## Files Generated

All legal documents have been converted to HTML format in the `legal/pdf/` directory. These HTML files include professional styling and can be easily converted to PDF.

## How to Create PDFs

Since your system doesn't have a LaTeX installation, the documents have been converted to HTML. You have several options to create PDFs:

### Option 1: Browser Print-to-PDF (Recommended)
1. Open any HTML file in your browser:
   ```bash
   open legal/pdf/articles-of-incorporation.html
   ```
2. Press `Cmd+P` (Mac) or `Ctrl+P` (PC) to open print dialog
3. Select "Save as PDF" as the destination
4. Ensure margins are set to 1 inch
5. Save the PDF

### Option 2: Install a PDF Engine
Install one of these tools to enable direct PDF generation:

**On Mac:**
```bash
# Option A: wkhtmltopdf (recommended)
brew install --cask wkhtmltopdf

# Option B: weasyprint
pip3 install weasyprint

# Option C: Install BasicTeX for LaTeX support
brew install --cask basictex
```

After installing, run the appropriate script again:
```bash
./generate-legal-pdfs.sh          # If you installed LaTeX
./generate-legal-pdfs-html.sh     # If you installed wkhtmltopdf or weasyprint
```

## Available Scripts

1. **generate-legal-pdfs.sh** - Full-featured script (requires LaTeX)
2. **generate-legal-pdfs-simple.sh** - Basic script (requires LaTeX)
3. **generate-legal-pdfs-html.sh** - HTML-based script (works without LaTeX)

## Document List

The following documents are available:
- Articles of Incorporation
- Corporate Bylaws  
- Mission, Vision, and Values
- Conflict of Interest Policy
- Financial Policies and Procedures
- Board Member Agreement
- Initial Board Resolution
- Form 1023 Eligibility Worksheet
- EIN Application Guide
- Nonprofit Formation Status

## Styling

The HTML files use professional legal document styling with:
- Letter-size pages with 1-inch margins
- Times New Roman body text
- Arial headings
- Proper spacing and formatting for legal documents
- Print-optimized CSS

## Regenerating Documents

To regenerate after making changes to the Markdown files:
```bash
./generate-legal-pdfs-html.sh
```

To convert a single document:
```bash
./generate-legal-pdfs-html.sh bylaws
```

## Notes

- PDFs are excluded from Git via .gitignore
- Review all documents before using officially
- Consider having a lawyer review before filing
