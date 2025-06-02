#!/bin/bash

# EduBox Legal Documents PDF Generator (HTML intermediate)
# Converts Markdown -> HTML -> PDF to avoid LaTeX dependencies

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LEGAL_DIR="$SCRIPT_DIR/legal"
PDF_DIR="$LEGAL_DIR/pdf"

# Create PDF directory if it doesn't exist
mkdir -p "$PDF_DIR"

echo -e "${BLUE}EduBox Legal Documents PDF Generator${NC}"
echo "===================================="
echo ""

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: Pandoc is not installed or not in PATH${NC}"
    echo "Please install Pandoc from: https://pandoc.org/installing.html"
    exit 1
fi

# Check for available PDF engines
echo "Checking for PDF generation options..."
PDF_ENGINE=""

# Try different PDF engines
if command -v wkhtmltopdf &> /dev/null; then
    PDF_ENGINE="wkhtmltopdf"
    echo -e "${GREEN}Found: wkhtmltopdf${NC}"
elif command -v weasyprint &> /dev/null; then
    PDF_ENGINE="weasyprint"
    echo -e "${GREEN}Found: weasyprint${NC}"
elif command -v prince &> /dev/null; then
    PDF_ENGINE="prince"
    echo -e "${GREEN}Found: prince${NC}"
else
    echo -e "${YELLOW}No PDF engine found. Will try alternative methods.${NC}"
fi

echo ""

# CSS for professional document styling
create_css() {
    cat > "$PDF_DIR/legal-style.css" << 'EOF'
@page {
    size: letter;
    margin: 1in;
}

body {
    font-family: 'Times New Roman', Times, serif;
    font-size: 11pt;
    line-height: 1.5;
    color: #000;
    max-width: 6.5in;
    margin: 0 auto;
}

h1, h2, h3, h4, h5, h6 {
    font-family: Arial, Helvetica, sans-serif;
    margin-top: 1em;
    margin-bottom: 0.5em;
}

h1 {
    font-size: 18pt;
    text-align: center;
    border-bottom: 2px solid #000;
    padding-bottom: 0.5em;
}

h2 {
    font-size: 14pt;
    margin-top: 1.5em;
}

h3 {
    font-size: 12pt;
}

p {
    text-align: justify;
    margin-bottom: 0.5em;
}

ul, ol {
    margin-left: 0.5in;
}

blockquote {
    margin-left: 0.5in;
    margin-right: 0.5in;
    font-style: italic;
}

strong {
    font-weight: bold;
}

hr {
    border: none;
    border-top: 1px solid #000;
    margin: 2em 0;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 1em 0;
}

th, td {
    border: 1px solid #000;
    padding: 0.5em;
    text-align: left;
}

th {
    background-color: #f0f0f0;
    font-weight: bold;
}

.signature-line {
    border-bottom: 1px solid #000;
    width: 3in;
    margin: 2em 0 0.5em 0;
    display: inline-block;
}

@media print {
    body {
        font-size: 11pt;
    }
    h1, h2, h3 {
        page-break-after: avoid;
    }
    table, blockquote {
        page-break-inside: avoid;
    }
}
EOF
}

# Function to convert using wkhtmltopdf
convert_with_wkhtmltopdf() {
    local html_file="$1"
    local pdf_file="$2"
    
    wkhtmltopdf \
        --page-size Letter \
        --margin-top 25mm \
        --margin-bottom 25mm \
        --margin-left 25mm \
        --margin-right 25mm \
        --encoding utf-8 \
        --enable-local-file-access \
        "$html_file" "$pdf_file" 2>/dev/null
}

# Function to convert using weasyprint
convert_with_weasyprint() {
    local html_file="$1"
    local pdf_file="$2"
    
    weasyprint "$html_file" "$pdf_file" 2>/dev/null
}

# Function to convert a single file
convert_file() {
    local input_file="$1"
    local filename=$(basename "$input_file" .md)
    local html_file="$PDF_DIR/${filename}.html"
    local pdf_file="$PDF_DIR/${filename}.pdf"
    
    echo -e "${BLUE}Converting:${NC} $filename.md -> $filename.pdf"
    
    # Get document title
    local title=""
    case "$filename" in
        "articles-of-incorporation")
            title="Articles of Incorporation - EduBox Global Initiative"
            ;;
        "bylaws")
            title="Corporate Bylaws - EduBox Global Initiative"
            ;;
        "mission-vision-values")
            title="Mission, Vision, and Values - EduBox Global Initiative"
            ;;
        *)
            title="$filename - EduBox Global Initiative"
            ;;
    esac
    
    # First convert to HTML with styling
    echo "  Converting to HTML..."
    if pandoc "$input_file" \
        --standalone \
        --metadata title="$title" \
        --metadata date="$(date +'%B %d, %Y')" \
        --css="legal-style.css" \
        --to=html5 \
        --toc \
        --toc-depth=3 \
        -o "$html_file"; then
        
        # Try to convert HTML to PDF
        if [[ -n "$PDF_ENGINE" ]]; then
            echo "  Converting to PDF with $PDF_ENGINE..."
            case "$PDF_ENGINE" in
                "wkhtmltopdf")
                    if convert_with_wkhtmltopdf "$html_file" "$pdf_file"; then
                        echo -e "${GREEN}✓ Success${NC}"
                        rm "$html_file"  # Clean up HTML file
                        return 0
                    fi
                    ;;
                "weasyprint")
                    if convert_with_weasyprint "$html_file" "$pdf_file"; then
                        echo -e "${GREEN}✓ Success${NC}"
                        rm "$html_file"  # Clean up HTML file
                        return 0
                    fi
                    ;;
            esac
        fi
        
        # If PDF conversion failed or no engine, try pandoc with different engines
        echo "  Trying alternative PDF generation..."
        
        # Try with context (ConTeXt)
        if pandoc "$input_file" --pdf-engine=context -o "$pdf_file" 2>/dev/null; then
            echo -e "${GREEN}✓ Success (ConTeXt)${NC}"
            rm "$html_file"
            return 0
        fi
        
        # Try HTML output (user can print to PDF from browser)
        echo -e "${YELLOW}✓ HTML generated (open in browser to print to PDF)${NC}"
        return 0
    fi
    
    echo -e "${RED}✗ Failed${NC}"
    return 1
}

# Create CSS file
create_css

# Process command line argument for single file conversion
if [[ $# -eq 1 ]]; then
    if [[ -f "$LEGAL_DIR/$1.md" ]]; then
        convert_file "$LEGAL_DIR/$1.md"
        exit $?
    else
        echo -e "${RED}Error: File '$1.md' not found in legal directory${NC}"
        exit 1
    fi
fi

# Convert all markdown files
echo "Converting all legal documents..."
echo ""

success_count=0
fail_count=0
html_count=0

for md_file in "$LEGAL_DIR"/*.md; do
    if [[ -f "$md_file" ]]; then
        if convert_file "$md_file"; then
            if [[ -f "$PDF_DIR/$(basename "$md_file" .md).pdf" ]]; then
                ((success_count++))
            else
                ((html_count++))
            fi
        else
            ((fail_count++))
        fi
        echo ""
    fi
done

# Summary
echo "===================================="
echo -e "${GREEN}Conversion complete!${NC}"
if [[ $success_count -gt 0 ]]; then
    echo "  PDF files: $success_count"
fi
if [[ $html_count -gt 0 ]]; then
    echo -e "  ${YELLOW}HTML files: $html_count (print to PDF from browser)${NC}"
fi
if [[ $fail_count -gt 0 ]]; then
    echo -e "  ${RED}Failed: $fail_count files${NC}"
fi
echo ""
echo "Files saved to: $PDF_DIR"
echo ""

# List generated files
if [[ $success_count -gt 0 ]] || [[ $html_count -gt 0 ]]; then
    echo "Generated files:"
    for file in "$PDF_DIR"/*.{pdf,html} 2>/dev/null; do
        if [[ -f "$file" ]]; then
            size=$(ls -lh "$file" | awk '{print $5}')
            name=$(basename "$file")
            echo "  - $name ($size)"
        fi
    done
fi

echo ""

if [[ $html_count -gt 0 ]] && [[ $success_count -eq 0 ]]; then
    echo -e "${YELLOW}Note: No PDF engine found on your system.${NC}"
    echo "HTML files were generated instead. You can:"
    echo "1. Open the HTML files in your browser and print to PDF"
    echo "2. Install a PDF engine:"
    echo "   - Mac: brew install wkhtmltopdf"
    echo "   - Mac: pip install weasyprint"
    echo "   - Linux: apt-get install wkhtmltopdf"
    echo ""
fi

echo "To view files:"
echo "  open \"$PDF_DIR\""
