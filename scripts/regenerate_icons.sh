#!/bin/bash

# App Icon Regeneration Script for CC Chat
# This script regenerates all platform-specific app icons from the SVG design

set -e  # Exit on any error

echo "🎨 CC Chat App Icon Regeneration"
echo "================================="

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: This script must be run from the project root directory"
    exit 1
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required but not installed"
    exit 1
fi

# Check if required Python packages are installed
echo "🔍 Checking Python dependencies..."
python3 -c "import PIL, cairosvg" 2>/dev/null || {
    echo "📦 Installing required Python packages..."
    pip3 install Pillow cairosvg
}

# Generate icons
echo "🚀 Generating app icons..."
python3 tools/generate_app_icons.py

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Icons generated successfully!"
    
    # Clean Flutter build cache
    echo "🧹 Cleaning Flutter build cache..."
    flutter clean
    
    # Get dependencies
    echo "📦 Getting Flutter dependencies..."
    flutter pub get
    
    echo ""
    echo "🎉 Icon regeneration completed!"
    echo ""
    echo "📋 What was updated:"
    echo "  • Android: 5 icons in mipmap folders"
    echo "  • iOS: 15 icons in AppIcon.appiconset"
    echo "  • macOS: 7 icons in AppIcon.appiconset"
    echo "  • Windows: 4 ICO files in resources"
    echo ""
    echo "🚀 Next steps:"
    echo "  1. Test the app on different platforms"
    echo "  2. Verify icons appear correctly"
    echo "  3. Update app store assets if needed"
    
else
    echo "❌ Icon generation failed. Check the errors above."
    exit 1
fi