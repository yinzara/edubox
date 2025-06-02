#!/bin/bash

# EduBox Legal Documents PDF Generator (Simple Version)
# Converts all Markdown files to PDF using basic Pandoc settings

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LEGAL_DIR="$SCRIPT_DIR/legal"
PDF_DIR="$LEGAL_DIR/pdf"

# Create PDF directory if it doesn't exist
mkdir -p "$PDF_DIR"

echo -e "${BLUE}EduBox Legal Documents PDF Generator (Simple)${NC}"
echo "============================================="
echo ""

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: Pandoc is not installed or not in PATH${NC}"
    echo "Please install Pandoc from: https://pandoc.org/installing.html"
    exit 1
fi

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
            title="Articles of Incorporation - EduBox Global Initiative"
            ;;
        "bylaws")
            title="Corporate Bylaws - EduBox Global Initiative"
            ;;
        "mission-vision-values")
            title="Mission, Vision, and Values - EduBox Global Initiative"
            ;;
        "conflict-of-interest-policy")
            title="Conflict of Interest Policy - EduBox Global Initiative"
            ;;
        "financial-policies-procedures")
            title="Financial Policies and Procedures - EduBox Global Initiative"
            ;;
        "board-member-agreement")
            title="Board Member Agreement - EduBox Global Initiative"
            ;;
        "initial-board-resolution")
            title="Initial Board Resolution - EduBox Global Initiative"
            ;;
        "form-1023-eligibility-worksheet")
            title="Form 1023 Eligibility Worksheet - EduBox Global Initiative"
            ;;
        "ein-application-guide")
            title="EIN Application Guide - EduBox Global Initiative"
            ;;
        "nonprofit-formation-status")
            title="Nonprofit Formation Status - EduBox Global Initiative"
            ;;
        *)
            title="$filename - EduBox Global Initiative"
            ;;
    esac
    
    # Convert with basic options that work without LaTeX
    if pandoc "$input_file" \
        -o "$output_file" \
        --metadata title="$title" \
        --metadata date="$(date +'%B %d, %Y')" \
        --standalone \
        --toc \
        --toc-depth=3 \
        -V geometry:margin=1in \
        -V fontsize=11pt \
        -V documentclass=article \
        2>/dev/null; then
        echo -e "${GREEN}✓ Success${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed${NC}"
        return 1
    fi
}

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
    if [[ -f "$md_file" ]]; then
        if convert_file "$md_file"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        echo ""
    fi
done

# Summary
echo "============================================="
echo -e "${GREEN}Conversion complete!${NC}"
echo "  Success: $success_count files"
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
echo "To convert a single file:"
echo "  ./generate-legal-pdfs-simple.sh filename"
echo "  (without the .md extension)"
