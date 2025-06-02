#!/bin/bash

# EduBox Legal Documents PDF Generator (XeLaTeX for Unicode support)

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

# Add BasicTeX to PATH
export PATH="/Library/TeX/texbin:$PATH"

# Create PDF directory if it doesn't exist
mkdir -p "$PDF_DIR"

echo -e "${BLUE}EduBox Legal Documents PDF Generator (Unicode Safe)${NC}"
echo "==================================================="
echo ""

# Check for available engines
if command -v xelatex &> /dev/null; then
    PDF_ENGINE="xelatex"
    echo -e "${GREEN}Found XeLaTeX (supports Unicode/emojis)${NC}"
elif command -v pdflatex &> /dev/null; then
    PDF_ENGINE="pdflatex"
    echo -e "${YELLOW}Found pdflatex (emojis will be removed)${NC}"
else
    echo -e "${RED}Error: No LaTeX engine found${NC}"
    exit 1
fi

echo ""

# Function to remove emojis and special Unicode characters
remove_emojis() {
    local input_file="$1"
    local output_file="$2"
    
    # Remove common emojis and replace with text equivalents
    sed -E '
        s/⚠️/WARNING:/g
        s/📋/[List]/g
        s/📝/[Note]/g
        s/🚀/[Action]/g
        s/💰/[Cost]/g
        s/📱/[Phone]/g
        s/⏱️/[Time]/g
        s/📌/[Important]/g
        s/🆘/[Help]/g
        s/✅/[Complete]/g
        s/🎯/[Target]/g
        s/🛠️/[Tools]/g
        s/🌐/[Web]/g
        s/📄/[Document]/g
        s/🎨/[Design]/g
        s/🔄/[Repeat]/g
        s/📝/[Write]/g
        s/📊/[Data]/g
        s/🔑/[Key]/g
        s/💡/[Tip]/g
        s/🌍/[Global]/g
        s/📚/[Books]/g
        s/🌟/[Star]/g
        s/🎉/[Celebrate]/g
        s/[✓✔]/[YES]/g
        s/[✗✘]/[NO]/g
        s/[•·]/*/g
        s/[""]/"/g
        s/['']/'\''/g
        s/[—–]/-/g
        s/…/.../g
    ' "$input_file" > "$output_file"
}

# Function to convert a single file
convert_file() {
    local input_file="$1"
    local filename=$(basename "$input_file" .md)
    local output_file="$PDF_DIR/${filename}.pdf"
    local temp_file="/tmp/${filename}_cleaned.md"
    
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
    
    # Clean the file if using pdflatex
    if [[ "$PDF_ENGINE" == "pdflatex" ]]; then
        echo "  Removing Unicode characters..."
        remove_emojis "$input_file" "$temp_file"
        input_file="$temp_file"
    fi
    
    # Convert to PDF
    if [[ "$PDF_ENGINE" == "xelatex" ]]; then
        # XeLaTeX supports Unicode
        if pandoc "$input_file" \
            -o "$output_file" \
            --pdf-engine=xelatex \
            --metadata title="$title" \
            --metadata subtitle="EduBox Global Initiative" \
            --metadata date="$(date +'%B %d, %Y')" \
            -V geometry:margin=1in \
            -V fontsize=11pt \
            -V mainfont="Arial" \
            -V monofont="Courier New" \
            -V linkcolor=blue \
            -V urlcolor=blue \
            --toc \
            --toc-depth=3 \
            2>/dev/null; then
            echo -e "${GREEN}✓ Success${NC}"
            rm -f "$temp_file"
            return 0
        fi
    fi
    
    # Try with pdflatex (or as fallback)
    echo "  Converting with $PDF_ENGINE..."
    if pandoc "$input_file" \
        -o "$output_file" \
        --pdf-engine=$PDF_ENGINE \
        --metadata title="$title" \
        --metadata subtitle="EduBox Global Initiative" \
        --metadata date="$(date +'%B %d, %Y')" \
        -V geometry:margin=1in \
        -V fontsize=11pt \
        -V linkcolor=blue \
        -V urlcolor=blue \
        --highlight-style=tango \
        2>/dev/null; then
        echo -e "${GREEN}✓ Success${NC}"
        rm -f "$temp_file"
        return 0
    else
        echo -e "${RED}✗ Failed${NC}"
        rm -f "$temp_file"
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

# First, convert the successfully converted ones
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
echo "==================================================="
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
echo "To view all PDFs:"
echo "  open \"$PDF_DIR\"/"
echo ""
echo "To view a specific PDF:"
echo "  open \"$PDF_DIR/filename.pdf\""
