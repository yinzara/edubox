#!/bin/bash

# Open all legal document HTML files for review/printing

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PDF_DIR="$SCRIPT_DIR/legal/pdf"

echo "Opening legal documents in browser..."
echo "Use Cmd+P to print each document to PDF"
echo ""

# Open each HTML file
for html_file in "$PDF_DIR"/*.html; do
    if [[ -f "$html_file" ]] && [[ "$html_file" != *"legal-style.css"* ]]; then
        filename=$(basename "$html_file")
        echo "Opening: $filename"
        open "$html_file"
        sleep 1  # Brief pause between opening files
    fi
done

echo ""
echo "All documents opened."
echo "To save as PDF: Press Cmd+P and select 'Save as PDF'"
