#!/bin/bash

# EduBox Legal Documents PDF Generator with BasicTeX

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LEGAL_DIR="$SCRIPT_DIR/legal"
PDF_DIR="$LEGAL_DIR/pdf"

# Add BasicTeX to PATH
export PATH="/Library/TeX/texbin:$PATH"

# Create PDF directory if it doesn't exist
mkdir -p "$PDF_DIR"

echo -e "${BLUE}EduBox Legal Documents PDF Generator (BasicTeX)${NC}"
echo "==============================================="
echo ""

# Check if pdflatex is now available
if ! command -v pdflatex &> /dev/null; then
    echo -e "${RED}Error: pdflatex not found even after adding BasicTeX to PATH${NC}"
    echo "Please ensure BasicTeX is properly installed."
    echo "You may need to restart your terminal or run:"
    echo "  eval \"\$(/usr/libexec/path_helper)\""
    exit 1
fi

echo -e "${GREEN}Found pdflatex at: $(which pdflatex)${NC}"
echo ""

# Function to convert a single file
convert_file() {
    local input_file="$1"
    local filename=$(basename "$input_file" .md)
    local output_file="$PDF_DIR/${filename}.pdf"
    
    echo -e "${BLUE}Converting:${NC} $filename.md -> $filename.pdf"
    
    # Add document-specific title
    local title=""
    case "$filename" in
        "articles-of-incorporation")
            title="Articles of Incorporation"
            ;;
        "bylaws")
            title="Corporate Bylaws"
            ;;
        "mission-vision-values")
            title="Mission, Vision, and Values"
            ;;
        "conflict-of-interest-policy")
            title="Conflict of Interest Policy"
            ;;
        "financial-policies-procedures")
            title="Financial Policies and Procedures"
            ;;
        "board-member-agreement")
            title="Board Member Agreement"
            ;;
        "initial-board-resolution")
            title="Initial Board Resolution"
            ;;
        "form-1023-eligibility-worksheet")
            title="Form 1023 Eligibility Worksheet"
            ;;
        "ein-application-guide")
            title="EIN Application Guide"
            ;;
        "nonprofit-formation-status")
            title="Nonprofit Formation Status"
            ;;
        *)
            title="$filename"
            ;;
    esac
    
    # Convert to PDF using pandoc with pdflatex
    if pandoc "$input_file" \
        -o "$output_file" \
        --pdf-engine=pdflatex \
        --metadata title="$title" \
        --metadata subtitle="EduBox Global Initiative" \
        --metadata date="$(date +'%B %d, %Y')" \
        -V geometry:margin=1in \
        -V fontsize=11pt \
        -V linkcolor=blue \
        -V urlcolor=blue \
        -V toccolor=black \
        --toc \
        --toc-depth=3 \
        --highlight-style=tango \
        2>/dev/null; then
        echo -e "${GREEN}✓ Success${NC}"
        return 0
    else
        # Try without table of contents if it fails
        echo "  Trying without table of contents..."
        if pandoc "$input_file" \
            -o "$output_file" \
            --pdf-engine=pdflatex \
            --metadata title="$title" \
            --metadata subtitle="EduBox Global Initiative" \
            --metadata date="$(date +'%B %d, %Y')" \
            -V geometry:margin=1in \
            -V fontsize=11pt \
            2>/dev/null; then
            echo -e "${GREEN}✓ Success (no TOC)${NC}"
            return 0
        else
            echo -e "${RED}✗ Failed${NC}"
            return 1
        fi
    fi
}

# Clean up old HTML files if they exist
echo "Cleaning up old HTML files..."
rm -f "$PDF_DIR"/*.html
echo ""

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
echo "Converting all legal documents to PDF..."
echo ""

success_count=0
fail_count=0

for md_file in "$LEGAL_DIR"/*.md; do
    if [[ -f "$md_file" && "$md_file" != */PDF-README.md ]]; then
        if convert_file "$md_file"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        echo ""
    fi
done

# Summary
echo "==============================================="
echo -e "${GREEN}Conversion complete!${NC}"
echo "  Success: $success_count PDF files"
if [[ $fail_count -gt 0 ]]; then
    echo -e "  ${RED}Failed: $fail_count files${NC}"
fi
echo ""
echo "PDFs saved to: $PDF_DIR"
echo ""

# List generated PDFs with file sizes
if [[ $success_count -gt 0 ]]; then
    echo "Generated PDFs:"
    for pdf in "$PDF_DIR"/*.pdf; do
        if [[ -f "$pdf" ]]; then
            size=$(ls -lh "$pdf" | awk '{print $5}')
            name=$(basename "$pdf")
            echo "  - $name ($size)"
        fi
    done
fi

echo ""
echo "To view a PDF:"
echo "  open \"$PDF_DIR/filename.pdf\""
echo ""
echo "To open all PDFs:"
echo "  open \"$PDF_DIR\"/*.pdf"
