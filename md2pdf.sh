#!/bin/bash

# Initialize variables
anonymous=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--anonymous)
            anonymous=true
            shift
            ;;
        -*)
            echo "Unknown option $1"
            echo "Usage: $0 [-a|--anonymous] <input_file>"
            echo "  -a, --anonymous    Generate PDF without personal information in footer"
            echo "Example: $0 document.md"
            echo "Example: $0 --anonymous document.md"
            exit 1
            ;;
        *)
            input_file="$1"
            shift
            ;;
    esac
done

# Check if input file is provided
if [ -z "$input_file" ]; then
    echo "Usage: $0 [-a|--anonymous] <input_file>"
    echo "  -a, --anonymous    Generate PDF without personal information in footer"
    echo "Example: $0 document.md"
    echo "Example: $0 --anonymous document.md"
    exit 1
fi

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found!"
    exit 1
fi

# Extract filename without extension
filename=$(basename "$input_file")
name_without_ext="${filename%.*}"

# Format title: replace hyphens/underscores with spaces and capitalize each word
formatted_title=$(echo "$name_without_ext" | sed 's/[-_]/ /g' | sed 's/\b\w/\U&/g')

# Set output filename
output_file="${name_without_ext}.pdf"

# Set footer content based on anonymous flag
if [ "$anonymous" = true ]; then
    footer_left=""
else
    footer_left="Alessandro Amella - P.IVA: 04183560368"
fi

# Run pandoc command
pandoc "$input_file" -o "$output_file" \
  --pdf-engine=xelatex \
  --template=eisvogel \
  --top-level-division=chapter \
  -V mainfont="Fira Sans" \
  -V fontsize=12pt \
  -V geometry="left=0.8in,right=0.8in,top=1.25in,bottom=1.25in" \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V documentclass=scrbook \
  -V book=true \
  -V title="$formatted_title" \
  -V header-left="$formatted_title" \
  -V footer-left="$footer_left" \
  -V footer-right="\\thepage"

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo "Successfully converted '$input_file' to '$output_file'"
else
    echo "Error: Conversion failed!"
    exit 1
fi