#!/bin/bash

# Personal info for footer - change this as needed!
FOOTER_TEXT="Alessandro Amella - P.IVA: 04183560368" 

# Function to display usage information
show_usage() {
    cat << EOF
Usage: $0 [-a|--anonymous] [-t|--toc] [-l|--lang <lang>] [-f|--format] [--title <title>] [--footer <text>] <input_file>
  -h, --help         Show this help message
  -a, --anonymous    Generate PDF without personal information in footer
  -t, --toc          Generate table of contents
  -l, --lang <lang>  Set TOC language (default: english, use 'italian' for Italian)
  -f, --format       Format markdown with Prettier before conversion
  --title <title>    Set custom title (overrides automatic formatting)
  --footer <text>    Set custom footer text (overrides default)
Example: $0 document.md
Example: $0 --anonymous --toc --title "My Custom Title" document.md
Example: $0 --format --footer "Custom Footer Text" document.md
EOF
}

# Initialize variables
anonymous=false
toc=false
toc_lang="english"  # default language
format=false
custom_title=""
custom_footer=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -a|--anonymous)
            anonymous=true
            shift
            ;;
        -t|--toc)
            toc=true
            shift
            ;;
        -l|--lang)
            toc_lang="$2"
            shift 2
            ;;
        -f|--format)
            format=true
            shift
            ;;
        --title)
            custom_title="$2"
            shift 2
            ;;
        --footer)
            custom_footer="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option $1"
            show_usage
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
    show_usage
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

# Use custom title if provided, otherwise use formatted title
if [ -n "$custom_title" ]; then
    final_title="$custom_title"
else
    final_title="$formatted_title"
fi

# Set output filename
output_file="${name_without_ext}.pdf"

# Format markdown with Prettier if requested
if [ "$format" = true ]; then
    temp_formatted_md=$(mktemp --suffix=.md)
    trap "rm -f '$temp_formatted_md'" EXIT

    echo "Formatting markdown with Prettier..."
    if pnpx prettier --parser markdown "$input_file" > "$temp_formatted_md" 2>/dev/null; then
        # Print where temp file is stored for debugging
        echo "Temporary formatted markdown file: $temp_formatted_md"
        # Use the formatted file for conversion
        input_file="$temp_formatted_md"
    else
        echo "Warning: Prettier formatting failed, using original file"
        # Clean up temp file if prettier failed
        rm -f "$temp_formatted_md"
    fi
fi

# Set footer content based on custom footer, anonymous flag, or default
if [ -n "$custom_footer" ]; then
    footer_left="$custom_footer"
elif [ "$anonymous" = true ]; then
    footer_left=""
else
    footer_left="$FOOTER_TEXT"
fi

# Build pandoc command with optional TOC
pandoc_cmd="pandoc \"$input_file\" -o \"$output_file\" \
  --pdf-engine=xelatex \
  --template=eisvogel \
  --top-level-division=chapter"

# Add TOC flags if requested
if [ "$toc" = true ]; then
    pandoc_cmd="$pandoc_cmd --toc --toc-depth=3 -V lang=$toc_lang"
fi

# Add remaining options
pandoc_cmd="$pandoc_cmd \
  -V mainfont=\"Fira Sans\" \
  -V fontsize=12pt \
  -V geometry=\"left=0.8in,right=0.8in,top=1.25in,bottom=1.25in\" \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V documentclass=scrbook \
  -V book=true \
  -V classoption=oneside \
  -V title=\"$final_title\" \
  -V header-left=\"$final_title\" \
  -V footer-left=\"$footer_left\" \
  -V footer-right=\"\\\\thepage\""

# Run pandoc command
eval $pandoc_cmd

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo "Successfully converted '$input_file' to '$output_file'"
else
    echo "Error: Conversion failed!"
    exit 1
fi
