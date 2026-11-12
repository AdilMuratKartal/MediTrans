#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: generate_feature.sh <feature_name> [--dark] [--with-player]

Scaffolds a MediTrans feature directory under lib/features/<feature_name>/:
  models/<feature_name>_item.dart
  controllers/<feature_name>_controller.dart
  widgets/<feature_name>_glass_card.dart
  screens/<feature_name>_screen.dart

Options:
  --dark         Configure the generated screen for Sleep/Night cosmic mode (#0E111C).
  --with-player  Include a compact universal audio player slot in the generated screen.
  -h, --help     Show this help message.
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

FEATURE_NAME=""
IS_DARK=false
WITH_PLAYER=false

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --dark)
      IS_DARK=true
      ;;
    --with-player)
      WITH_PLAYER=true
      ;;
    -*)
      echo "Error: Unknown option '$arg'" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -n "$FEATURE_NAME" ]]; then
        echo "Error: Unexpected positional argument '$arg'" >&2
        usage
        exit 1
      fi
      FEATURE_NAME="$arg"
      ;;
  esac
done

if [[ -z "$FEATURE_NAME" ]]; then
  echo "Error: <feature_name> is required." >&2
  usage
  exit 1
fi

if [[ ! "$FEATURE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Error: <feature_name> must be lowercase snake_case (e.g. 'breathwork', 'sleep_stories')." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
FEATURE_DIR="$REPO_ROOT/lib/features/$FEATURE_NAME"

if [[ -e "$FEATURE_DIR" ]]; then
  echo "Error: Target directory already exists: $FEATURE_DIR" >&2
  echo "Refusing to overwrite existing feature files." >&2
  exit 1
fi

# Convert snake_case to PascalCase cleanly using awk/tr portability.
PASCAL_NAME="$(printf '%s' "$FEATURE_NAME" | awk -F_ '{
  for (i = 1; i <= NF; i++) {
    printf "%s%s", toupper(substr($i, 1, 1)), substr($i, 2)
  }
}')"

mkdir -p \
  "$FEATURE_DIR/models" \
  "$FEATURE_DIR/controllers" \
  "$FEATURE_DIR/widgets" \
  "$FEATURE_DIR/screens"

cat >"$FEATURE_DIR/models/${FEATURE_NAME}_item.dart" <<EOF
class ${PASCAL_NAME}Item {
  const ${PASCAL_NAME}Item({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageAsset,
    this.audioAsset,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? imageAsset;
  final String? audioAsset;
}
EOF

cat >"$FEATURE_DIR/controllers/${FEATURE_NAME}_controller.dart" <<EOF
import 'package:flutter/foundation.dart';

import '../models/${FEATURE_NAME}_item.dart';

class ${PASCAL_NAME}Controller extends ChangeNotifier {
  ${PASCAL_NAME}Controller({List<${PASCAL_NAME}Item> items = const []})
      : _items = items;

  final List<${PASCAL_NAME}Item> _items;
  int _selectedIndex = 0;

  List<${PASCAL_NAME}Item> get items => List.unmodifiable(_items);
  int get selectedIndex => _selectedIndex;
  ${PASCAL_NAME}Item? get activeItem =>
      _items.isEmpty ? null : _items[_selectedIndex];

  void selectIndex(int index) {
    if (index < 0 || index >= _items.length || index == _selectedIndex) {
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }
}
EOF

if [[ "$IS_DARK" == true ]]; then
  SURFACE_HEX="0xFF0E111C"
  CARD_HEX="0x99181D2D"
  BORDER_HEX="0x33FFFFFF"
  FG_HEX="0xFFFFFFFF"
  MUTED_HEX="0xFF9BA3B7"
else
  SURFACE_HEX="0xFFFBF8FF"
  CARD_HEX="0x73FFFFFF"
  BORDER_HEX="0xA6FFFFFF"
  FG_HEX="0xFF1A1D2B"
  MUTED_HEX="0xFF6A7188"
fi

cat >"$FEATURE_DIR/widgets/${FEATURE_NAME}_glass_card.dart" <<EOF
import 'dart:ui';

import 'package:flutter/material.dart';

class ${PASCAL_NAME}GlassCard extends StatelessWidget {
  const ${PASCAL_NAME}GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color($CARD_HEX),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: const Color($BORDER_HEX)),
          ),
          child: child,
        ),
      ),
    );
  }
}
EOF

PLAYER_BLOCK=""
if [[ "$WITH_PLAYER" == true ]]; then
  PLAYER_BLOCK="$(cat <<EOF
            const SizedBox(height: 16),
            ${PASCAL_NAME}GlassCard(
              borderRadius: 28,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: const [
                  Icon(Icons.replay_10_rounded, color: Color($FG_HEX)),
                  Spacer(),
                  Icon(Icons.play_circle_filled_rounded,
                      size: 44, color: Color(0xFF60538D)),
                  Spacer(),
                  Icon(Icons.forward_10_rounded, color: Color($FG_HEX)),
                ],
              ),
            ),
EOF
)"
fi

cat >"$FEATURE_DIR/screens/${FEATURE_NAME}_screen.dart" <<EOF
import 'package:flutter/material.dart';

import '../widgets/${FEATURE_NAME}_glass_card.dart';

class ${PASCAL_NAME}Screen extends StatelessWidget {
  const ${PASCAL_NAME}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color($SURFACE_HEX),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$PASCAL_NAME',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color($FG_HEX),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ethereal Aura Mind feature scaffold',
                style: TextStyle(
                  fontSize: 14,
                  color: Color($MUTED_HEX),
                ),
              ),
              const SizedBox(height: 20),
              ${PASCAL_NAME}GlassCard(
                child: const Text(
                  'Replace with domain content from project.md & state_flow.md.',
                  style: TextStyle(color: Color($FG_HEX)),
                ),
              ),
$PLAYER_BLOCK
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "Scaffolded feature '$FEATURE_NAME' at lib/features/$FEATURE_NAME"
echo "Next steps:"
echo "  1. Wire models and controllers to shared core theme & GlobalAudioController."
echo "  2. Register route in lib/core/navigation/ and add any new ASCII assets to pubspec.yaml."
echo "  3. Add widget tests under test/${FEATURE_NAME}_test.dart and run 'flutter analyze' + 'flutter test'."

