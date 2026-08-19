#!/usr/bin/env bash

# Applies the same formatters the editor runs on save, since agent writes never
# pass through the editor.

file=$(jq -r '.tool_input.file_path // empty')

test -n "$file" || exit 0
test -f "$file" || exit 0

case "$file" in
*/libraries/* | */vendor/* | */node_modules/* | */build/* | */.direnv/*) exit 0 ;;
esac

case "$file" in
*.c | *.h)
	# With no .clang-format in scope clang-format applies LLVM defaults, which
	# would restyle a project that never opted in.
	dir=$(dirname "$file")
	while [ "$dir" != "/" ] && [ "$dir" != "." ]; do
		if [ -f "$dir/.clang-format" ]; then
			clang-format -i "$file"
			break
		fi
		dir=$(dirname "$dir")
	done
	;;
*.go)
	gofmt -w "$file"
	;;
esac

exit 0
