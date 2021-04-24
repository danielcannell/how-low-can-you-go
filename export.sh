#!/bin/sh
set -eu

# Change to current script dir
cd "$(dirname $(readlink -f $0))"

# Pass path to godot exe as first argument
if [ $# != 1 ]; then
    echo "Usage: $0 <PATH_TO_GODOT_EXE>"
    exit 1
fi
GODOT="$1"

# Cleanup old exports
rm -rf export/ || true

# Export godot HTML5 template
mkdir -p export/
$GODOT "project.godot" --export "HTML5" export/index.html

# Patch index file to use 'not-a-wasm' as extension
mv export/index.wasm export/index.not-a-wasm
sed -i "s/engine.setCanvas(canvas);/\0 Engine.setWebAssemblyFilenameExtension('not-a-wasm');/" export/index.html
