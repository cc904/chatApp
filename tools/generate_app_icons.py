#!/usr/bin/env python3
"""
App Icon Generator for CC Chat Application

This script generates all required icon sizes for Android, iOS, macOS, and Windows
from a single SVG source file.

Requirements:
- Python 3.6+
- Pillow (PIL)
- cairosvg

Install dependencies:
pip install Pillow cairosvg

Usage:
python3 tools/generate_app_icons.py
"""

import os
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import io

# Try to import cairosvg
try:
    import cairosvg
except ImportError:
    print("❌ cairosvg not found. Installing...")
    os.system("pip3 install cairosvg")
    import cairosvg

# Project root directory
PROJECT_ROOT = Path(__file__).parent.parent
ICONS_DIR = PROJECT_ROOT / "assets" / "icons"
SVG_SOURCE = ICONS_DIR / "app_icon_design.svg"

# Platform-specific icon configurations
ICON_CONFIGS = {
    # Android icons (mipmap folders)
    "android": [
        {"size": 48, "path": "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"},
        {"size": 72, "path": "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"},
        {"size": 96, "path": "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"},
        {"size": 144, "path": "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"},
        {"size": 192, "path": "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"},
    ],
    
    # iOS icons (AppIcon.appiconset)
    "ios": [
        {"size": 20, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png"},
        {"size": 40, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png"},
        {"size": 60, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png"},
        {"size": 29, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png"},
        {"size": 58, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png"},
        {"size": 87, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png"},
        {"size": 40, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png"},
        {"size": 80, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png"},
        {"size": 120, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png"},
        {"size": 120, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png"},
        {"size": 180, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png"},
        {"size": 76, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png"},
        {"size": 152, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png"},
        {"size": 167, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png"},
        {"size": 1024, "path": "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"},
    ],
    
    # macOS icons
    "macos": [
        {"size": 16, "path": "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png"},
        {"size": 32, "path": "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png"},
        {"size": 64, "path": "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png"},
        {"size": 128, "path": "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png"},
        {"size": 256, "path": "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png"},
        {"size": 512, "path": "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png"},
        {"size": 1024, "path": "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png"},
    ],
    
    # Windows icons - 增加高分辨率支持
    "windows": [
        {"size": 16, "path": "windows/runner/resources/app_icon_16.ico"},
        {"size": 32, "path": "windows/runner/resources/app_icon_32.ico"},
        {"size": 48, "path": "windows/runner/resources/app_icon_48.ico"},
        {"size": 64, "path": "windows/runner/resources/app_icon_64.ico"},
        {"size": 128, "path": "windows/runner/resources/app_icon_128.ico"},
        {"size": 256, "path": "windows/runner/resources/app_icon_256.ico"},
        {"size": 512, "path": "windows/runner/resources/app_icon_512.ico"},
        {"size": 1024, "path": "windows/runner/resources/app_icon.ico"},  # 主图标使用最高分辨率
    ]
}

def create_rounded_icon(image, corner_radius_ratio=0.2237):
    """
    Create iOS-style rounded corner icon
    iOS uses approximately 22.37% corner radius relative to icon size
    """
    size = image.size[0]
    corner_radius = int(size * corner_radius_ratio)
    
    # Create mask for rounded corners
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, size, size], radius=corner_radius, fill=255)
    
    # Apply mask to image
    rounded_image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    rounded_image.paste(image, (0, 0))
    rounded_image.putalpha(mask)
    
    return rounded_image

def svg_to_png(svg_path, output_path, size):
    """Convert SVG to PNG with specified size and high quality"""
    try:
        # 对于高分辨率图标，使用更大的渲染尺寸然后缩放，以获得更好的质量
        render_size = size
        if size <= 64:
            # 小尺寸图标使用4倍超采样
            render_size = size * 4
        elif size <= 256:
            # 中等尺寸图标使用2倍超采样
            render_size = size * 2
        
        # Convert SVG to PNG using cairosvg with high quality settings
        png_data = cairosvg.svg2png(
            url=str(svg_path),
            output_width=render_size,
            output_height=render_size,
            dpi=300  # 高DPI渲染
        )
        
        # Open with PIL for further processing
        image = Image.open(io.BytesIO(png_data))
        
        # Ensure RGBA mode
        if image.mode != 'RGBA':
            image = image.convert('RGBA')
        
        # 如果使用了超采样，缩放到目标尺寸
        if render_size != size:
            image = image.resize((size, size), Image.Resampling.LANCZOS)
            # 对缩放后的小图标进行轻微锐化
            if size <= 64:
                image = image.filter(ImageFilter.UnsharpMask(radius=0.3, percent=120, threshold=1))
        
        return image
        
    except Exception as e:
        print(f"❌ Error converting SVG to PNG: {e}")
        return None

def generate_icons():
    """Generate all platform-specific icons"""
    
    if not SVG_SOURCE.exists():
        print(f"❌ SVG source file not found: {SVG_SOURCE}")
        return False
    
    print(f"🎨 Generating app icons from {SVG_SOURCE}")
    
    success_count = 0
    total_count = 0
    
    for platform, configs in ICON_CONFIGS.items():
        print(f"\n📱 Generating {platform.upper()} icons...")
        
        for config in configs:
            total_count += 1
            size = config["size"]
            output_path = PROJECT_ROOT / config["path"]
            
            # Ensure output directory exists
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            try:
                # Convert SVG to PNG
                image = svg_to_png(SVG_SOURCE, output_path, size)
                
                if image is None:
                    print(f"  ❌ Failed to generate {size}x{size} icon")
                    continue
                
                # Apply platform-specific processing
                if platform == "ios" and size != 1024:  # iOS needs rounded corners except for App Store
                    image = create_rounded_icon(image)
                elif platform == "macos":
                    # macOS icons should be slightly rounded
                    image = create_rounded_icon(image, corner_radius_ratio=0.1)
                
                # Save the image
                if output_path.suffix.lower() == '.ico':
                    # For ICO files (Windows), save with multiple sizes for better quality
                    # 根据目标尺寸决定包含的ICO尺寸
                    if size >= 1024:
                        # 主图标包含所有尺寸
                        ico_sizes = [(16, 16), (20, 20), (24, 24), (32, 32), (40, 40), (48, 48), 
                                   (64, 64), (96, 96), (128, 128), (256, 256), (512, 512), (1024, 1024)]
                    elif size >= 512:
                        ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256), (512, 512)]
                    elif size >= 256:
                        ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
                    elif size >= 128:
                        ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128)]
                    elif size >= 64:
                        ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64)]
                    else:
                        ico_sizes = [(size, size)]
                    
                    images = []
                    for ico_size in ico_sizes:
                        if ico_size[0] <= size:
                            # 使用高质量重采样算法
                            resized = image.resize(ico_size, Image.Resampling.LANCZOS)
                            # 对小尺寸图标进行锐化处理以提高清晰度
                            if ico_size[0] <= 48:
                                resized = resized.filter(ImageFilter.UnsharpMask(radius=0.5, percent=150, threshold=2))
                            images.append(resized)
                    
                    if images:
                        images[0].save(output_path, format='ICO', sizes=[(img.width, img.height) for img in images])
                else:
                    # Save as PNG
                    image.save(output_path, 'PNG')
                
                print(f"  ✅ Generated {size}x{size} → {output_path.name}")
                success_count += 1
                
            except Exception as e:
                print(f"  ❌ Failed to generate {size}x{size}: {e}")
    
    print(f"\n🎉 Icon generation completed!")
    print(f"✅ Successfully generated: {success_count}/{total_count} icons")
    
    return success_count == total_count

def update_ios_contents_json():
    """Update iOS AppIcon Contents.json to match generated icons"""
    
    contents_json = {
        "images": [
            {"filename": "Icon-App-20x20@1x.png", "idiom": "iphone", "scale": "1x", "size": "20x20"},
            {"filename": "Icon-App-20x20@2x.png", "idiom": "iphone", "scale": "2x", "size": "20x20"},
            {"filename": "Icon-App-20x20@3x.png", "idiom": "iphone", "scale": "3x", "size": "20x20"},
            {"filename": "Icon-App-29x29@1x.png", "idiom": "iphone", "scale": "1x", "size": "29x29"},
            {"filename": "Icon-App-29x29@2x.png", "idiom": "iphone", "scale": "2x", "size": "29x29"},
            {"filename": "Icon-App-29x29@3x.png", "idiom": "iphone", "scale": "3x", "size": "29x29"},
            {"filename": "Icon-App-40x40@1x.png", "idiom": "iphone", "scale": "1x", "size": "40x40"},
            {"filename": "Icon-App-40x40@2x.png", "idiom": "iphone", "scale": "2x", "size": "40x40"},
            {"filename": "Icon-App-40x40@3x.png", "idiom": "iphone", "scale": "3x", "size": "40x40"},
            {"filename": "Icon-App-60x60@2x.png", "idiom": "iphone", "scale": "2x", "size": "60x60"},
            {"filename": "Icon-App-60x60@3x.png", "idiom": "iphone", "scale": "3x", "size": "60x60"},
            {"filename": "Icon-App-76x76@1x.png", "idiom": "ipad", "scale": "1x", "size": "76x76"},
            {"filename": "Icon-App-76x76@2x.png", "idiom": "ipad", "scale": "2x", "size": "76x76"},
            {"filename": "Icon-App-83.5x83.5@2x.png", "idiom": "ipad", "scale": "2x", "size": "83.5x83.5"},
            {"filename": "Icon-App-1024x1024@1x.png", "idiom": "ios-marketing", "scale": "1x", "size": "1024x1024"}
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    contents_path = PROJECT_ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset" / "Contents.json"
    
    try:
        import json
        with open(contents_path, 'w', encoding='utf-8') as f:
            json.dump(contents_json, f, indent=2)
        print(f"✅ Updated iOS Contents.json")
        return True
    except Exception as e:
        print(f"❌ Failed to update iOS Contents.json: {e}")
        return False

def update_macos_contents_json():
    """Update macOS AppIcon Contents.json"""
    
    contents_json = {
        "images": [
            {"filename": "app_icon_16.png", "idiom": "mac", "scale": "1x", "size": "16x16"},
            {"filename": "app_icon_32.png", "idiom": "mac", "scale": "2x", "size": "16x16"},
            {"filename": "app_icon_32.png", "idiom": "mac", "scale": "1x", "size": "32x32"},
            {"filename": "app_icon_64.png", "idiom": "mac", "scale": "2x", "size": "32x32"},
            {"filename": "app_icon_128.png", "idiom": "mac", "scale": "1x", "size": "128x128"},
            {"filename": "app_icon_256.png", "idiom": "mac", "scale": "2x", "size": "128x128"},
            {"filename": "app_icon_256.png", "idiom": "mac", "scale": "1x", "size": "256x256"},
            {"filename": "app_icon_512.png", "idiom": "mac", "scale": "2x", "size": "256x256"},
            {"filename": "app_icon_512.png", "idiom": "mac", "scale": "1x", "size": "512x512"},
            {"filename": "app_icon_1024.png", "idiom": "mac", "scale": "2x", "size": "512x512"}
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    # First ensure the AppIcon.appiconset directory exists for macOS
    appiconset_dir = PROJECT_ROOT / "macos" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    appiconset_dir.mkdir(parents=True, exist_ok=True)
    
    contents_path = appiconset_dir / "Contents.json"
    
    try:
        import json
        with open(contents_path, 'w', encoding='utf-8') as f:
            json.dump(contents_json, f, indent=2)
        print(f"✅ Updated macOS Contents.json")
        return True
    except Exception as e:
        print(f"❌ Failed to update macOS Contents.json: {e}")
        return False

def main():
    """Main function"""
    print("🚀 CC Chat App Icon Generator")
    print("=" * 50)
    
    # Check if required dependencies are installed
    try:
        import cairosvg
        from PIL import Image
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("Please install required packages:")
        print("pip3 install Pillow cairosvg")
        return False
    
    # Generate all icons
    success = generate_icons()
    
    if success:
        # Update configuration files
        print("\n📝 Updating platform configuration files...")
        update_ios_contents_json()
        update_macos_contents_json()
        
        print("\n🎉 All icons generated successfully!")
        print("\n📋 Next steps:")
        print("1. Run 'flutter clean' to clear build cache")
        print("2. Run 'flutter pub get' to refresh dependencies")
        print("3. Rebuild your app to see the new icons")
        
        return True
    else:
        print("\n❌ Some icons failed to generate. Check the errors above.")
        return False

if __name__ == "__main__":
    main()