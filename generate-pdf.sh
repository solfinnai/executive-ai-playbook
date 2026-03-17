#!/bin/bash

# Executive AI Playbook - PDF Generation Script
# This script provides multiple options for converting the HTML playbook to PDF

set -e

HTML_FILE="playbook.html"
PDF_FILE="The-AI-Native-Company-Playbook.pdf"

echo "🚀 Executive AI Playbook - PDF Generator"
echo "========================================"

# Check if HTML file exists
if [ ! -f "$HTML_FILE" ]; then
    echo "❌ Error: $HTML_FILE not found in current directory"
    exit 1
fi

echo "✅ Found $HTML_FILE"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Option 1: Check for wkhtmltopdf
if command_exists wkhtmltopdf; then
    echo "🔧 Found wkhtmltopdf - using it to generate PDF..."
    wkhtmltopdf \
        --page-size Letter \
        --margin-top 1in \
        --margin-bottom 1in \
        --margin-left 1in \
        --margin-right 1in \
        --print-media-type \
        --enable-local-file-access \
        --disable-smart-shrinking \
        --zoom 1.0 \
        "$HTML_FILE" "$PDF_FILE"
    
    echo "✅ PDF generated successfully: $PDF_FILE"
    exit 0
fi

# Option 2: Check for Puppeteer (via npx)
if command_exists npx; then
    echo "🔧 Found npx - checking for Puppeteer..."
    if npx puppeteer --version >/dev/null 2>&1; then
        echo "🔧 Using Puppeteer to generate PDF..."
        
        # Create temporary Puppeteer script
        cat > temp_pdf_generator.js << 'EOF'
const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  const htmlPath = path.resolve('./playbook.html');
  await page.goto(`file://${htmlPath}`, { waitUntil: 'networkidle0' });
  
  await page.pdf({
    path: 'The-AI-Native-Company-Playbook.pdf',
    format: 'Letter',
    margin: {
      top: '1in',
      bottom: '1in',
      left: '1in',
      right: '1in'
    },
    printBackground: true,
    preferCSSPageSize: true
  });
  
  await browser.close();
  console.log('✅ PDF generated successfully: The-AI-Native-Company-Playbook.pdf');
})();
EOF
        
        npx puppeteer temp_pdf_generator.js
        rm temp_pdf_generator.js
        exit 0
    fi
fi

# Option 3: Check for Chrome/Chromium
if command_exists google-chrome || command_exists chromium-browser || command_exists chrome; then
    echo "🔧 Found Chrome - using headless mode..."
    
    CHROME_CMD=""
    if command_exists google-chrome; then
        CHROME_CMD="google-chrome"
    elif command_exists chromium-browser; then
        CHROME_CMD="chromium-browser"
    elif command_exists chrome; then
        CHROME_CMD="chrome"
    fi
    
    HTML_PATH="$(pwd)/$HTML_FILE"
    
    $CHROME_CMD \
        --headless \
        --disable-gpu \
        --print-to-pdf="$PDF_FILE" \
        --print-to-pdf-no-header \
        --no-margins \
        --run-all-compositor-stages-before-draw \
        --virtual-time-budget=25000 \
        "file://$HTML_PATH"
    
    echo "✅ PDF generated successfully: $PDF_FILE"
    exit 0
fi

# Manual fallback instructions
echo "❌ No automated PDF generation tools found."
echo ""
echo "📖 MANUAL INSTRUCTIONS:"
echo "======================"
echo ""
echo "1. Open the HTML file in Chrome or Safari:"
echo "   - Chrome: File → Open File → Select playbook.html"
echo "   - Safari: File → Open File → Select playbook.html"
echo ""
echo "2. Print to PDF:"
echo "   - Press Cmd+P (Mac) or Ctrl+P (Windows/Linux)"
echo "   - Choose 'Save as PDF' or 'Print to PDF'"
echo "   - Set paper size to 'Letter (8.5 x 11 in)'"
echo "   - Set margins to 'Minimum' or 'Custom' (1 inch all around)"
echo "   - ✅ IMPORTANT: Check 'Background graphics' or 'Print backgrounds'"
echo "   - Save as: The-AI-Native-Company-Playbook.pdf"
echo ""
echo "3. Alternative - Use any online HTML to PDF converter:"
echo "   - Upload playbook.html to services like:"
echo "   - htmlpdfapi.com"
echo "   - html-pdf-converter.com"
echo "   - smallpdf.com/html-to-pdf"
echo ""
echo "🛠️  To install automated tools:"
echo "==============================="
echo ""
echo "Option 1 - Install wkhtmltopdf:"
echo "  macOS:   brew install wkhtmltopdf"
echo "  Ubuntu:  sudo apt-get install wkhtmltopdf"
echo "  Windows: Download from https://wkhtmltopdf.org/downloads.html"
echo ""
echo "Option 2 - Install Puppeteer:"
echo "  npm install -g puppeteer"
echo ""
echo "Then run this script again for automatic conversion."

echo ""
echo "📄 Your HTML file is ready: $HTML_FILE"
echo "🎯 Target PDF name: $PDF_FILE"