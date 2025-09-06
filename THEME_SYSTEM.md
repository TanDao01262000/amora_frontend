# 🌸 Amora Theme System Documentation

## Overview

The Amora app features a comprehensive romantic theme system with beautiful pastel colors, animated gradients, seasonal overlays, and custom background support. This system creates an immersive and romantic experience for couples.

## 🎨 Color Palette

### Primary Colors
- **🌸 Love Pink (Primary)**: `#FADADD` - Soft blush for main UI elements
- **💜 Romance Purple (Secondary)**: `#E6E6FA` - Lavender for secondary elements
- **🌿 Fresh Love (Accent)**: `#B4E4D9` - Mint green for highlights
- **🍑 Soft Peach (Highlight)**: `#FFE5B4` - Warm peach for special elements

### Background Colors
- **⚪ White**: `#FFFFFF` - Clean background
- **🖤 Charcoal Grey**: `#333333` - Dark text
- **🤍 Warm Grey**: `#777777` - Light text

### Dark Theme Colors
- **Deep Navy**: `#1A1A2E` - Dark background
- **Dark Lavender**: `#2E294E` - Dark secondary
- **Light Grey**: `#EAEAEA` - Light text on dark

## 🌈 Theme Modes

### 1. Light Theme (Default)
- **Background**: White with soft blush pink gradient
- **Text**: Dark grey (#333)
- **Buttons**: Gradient pink → peach
- **Cards**: White with soft shadows
- **Atmosphere**: Bright and romantic pastel theme

### 2. Dark Theme (Romantic Night)
- **Background**: Deep navy with dark lavender gradient
- **Text**: White / light grey (#EAEAEA)
- **Buttons**: Gradient lavender → soft pink
- **Cards**: Dark with light pastel accents
- **Atmosphere**: Romantic night mode with deep colors

### 3. Custom Background Mode
- **Background**: User's own photo
- **Overlay**: Pastel gradient to match app's romantic vibe
- **Options**:
  - Full background image (stretch/fill)
  - Blurred background (for text readability)
  - Adjustable overlay opacity
- **Sources**: Camera capture or gallery selection

## 🎭 Components

### RomanticBackground
The main background widget that combines all theme features:
```dart
RomanticBackground(
  themeProvider: themeProvider,
  enableSeasonalOverlays: true,
  child: YourContent(),
)
```

### RomanticButton
Beautiful gradient buttons with romantic styling:
```dart
RomanticButton(
  text: 'Love Button',
  icon: Icons.favorite,
  isPrimary: true,
  onPressed: () => {},
)
```

### RomanticCard
Cards with soft shadows and optional gradient borders:
```dart
RomanticCard(
  hasGradientBorder: true,
  child: YourContent(),
)
```

### SeasonalOverlay
Automatic seasonal decorations:
- **Always**: Floating hearts for romantic atmosphere
- **Valentine's Day**: Enhanced heart animations
- **Christmas**: Falling snowflakes

## 🎪 Seasonal Features

### Floating Hearts
- **Always Active**: Creates romantic atmosphere
- **Animation**: Gentle floating motion with size changes
- **Customization**: Adjustable count and speed

### Valentine's Day (February 14)
- **Enhanced Hearts**: More prominent heart animations
- **Special Effects**: Increased romantic atmosphere
- **Automatic**: Triggers on Valentine's Day

### Christmas (December 25)
- **Snowflakes**: Animated falling snowflakes
- **Rotation**: Snowflakes rotate as they fall
- **Drift**: Horizontal drift motion for realism

## 🎬 Animations

### Animated Gradients
- **Duration**: 8-second cycles
- **Effect**: Soft color transitions
- **Direction**: Reversing animation for smooth flow

### Seasonal Animations
- **Hearts**: 3-second floating cycles
- **Snowflakes**: 4-second falling cycles
- **Performance**: Optimized for smooth 60fps

## ⚙️ Theme Provider

### Features
- **Persistence**: Saves theme preferences
- **Real-time**: Instant theme switching
- **Custom Backgrounds**: Image management
- **Settings**: Blur and opacity controls

### Usage
```dart
// Get current theme
final themeProvider = Provider.of<ThemeProvider>(context);

// Switch themes
await themeProvider.setThemeMode(ThemeMode.dark);

// Set custom background
await themeProvider.setCustomBackground(
  imagePath,
  blurred: true,
  opacity: 0.3,
);
```

## 🎨 Customization

### Adding New Colors
1. Add to `AppColors` class in `app_theme.dart`
2. Update gradients in `AppGradients`
3. Add to theme configurations

### Creating New Components
1. Follow the romantic design principles
2. Use the established color palette
3. Include soft shadows and rounded corners
4. Add gradient options where appropriate

### Seasonal Customizations
1. Add new dates to `SeasonalOverlay`
2. Create custom painters for new effects
3. Update the seasonal detection logic

## 📱 Usage Examples

### Basic Theme Setup
```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    // ... other providers
  ],
  child: Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return MaterialApp(
        theme: themeProvider.currentTheme,
        home: YourHomeScreen(),
      );
    },
  ),
)
```

### Using Romantic Components
```dart
// In your screen
RomanticBackground(
  themeProvider: themeProvider,
  child: Column(
    children: [
      RomanticCard(
        child: Text('Beautiful card content'),
      ),
      RomanticButton(
        text: 'Love Action',
        onPressed: () => {},
      ),
    ],
  ),
)
```

### Theme Settings Screen
Access the theme settings through:
- App bar theme button
- Settings menu
- Direct navigation to `/theme-settings`

## 🎯 Best Practices

### Design Principles
1. **Romantic**: Always maintain the romantic atmosphere
2. **Consistent**: Use the established color palette
3. **Smooth**: Ensure smooth animations and transitions
4. **Accessible**: Maintain good contrast ratios
5. **Performance**: Optimize animations for 60fps

### Implementation Tips
1. **Provider Usage**: Always use Provider for theme access
2. **Animation Control**: Dispose controllers properly
3. **Memory Management**: Optimize image handling for custom backgrounds
4. **User Experience**: Provide instant feedback for theme changes

## 🚀 Demo Screen

Access the theme demo at `/theme-demo` to see:
- All color swatches
- Gradient demonstrations
- Button variations
- Card examples
- Seasonal features
- Interactive theme switching

## 🔧 Technical Details

### Dependencies
- `provider`: State management
- `shared_preferences`: Theme persistence
- `image_picker`: Custom background selection

### File Structure
```
lib/
├── theme/
│   └── app_theme.dart          # Color definitions and themes
├── providers/
│   └── theme_provider.dart     # Theme state management
├── widgets/
│   ├── custom_background.dart  # Background implementations
│   └── romantic_background.dart # Main theme widgets
└── screens/
    ├── theme_settings_screen.dart # Settings UI
    └── theme_demo_screen.dart     # Demo showcase
```

### Performance Considerations
- **Animations**: Use `TickerProviderStateMixin` for smooth animations
- **Images**: Optimize custom background images
- **Memory**: Dispose animation controllers properly
- **Rendering**: Use `CustomPainter` for seasonal effects

## 💕 Conclusion

The Amora theme system creates a beautiful, romantic experience that adapts to user preferences and special occasions. The combination of pastel colors, smooth animations, and seasonal features makes every interaction feel special and romantic.

For questions or contributions to the theme system, please refer to the code documentation and follow the established patterns.
