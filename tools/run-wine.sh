#!/bin/sh
# Launches build/LEGOBionicle.exe on macOS/Linux.
# Uses CrossOver (bottle "LOMN-Beta", created on first run) if installed, otherwise plain Wine
# with a prefix in build/.wineprefix. Override with LOMN_BOTTLE, CROSSOVER_APP or WINEPREFIX.
set -e
cd "$(dirname "$0")/../build"
GAME_DIR="$PWD"
BOTTLE="${LOMN_BOTTLE:-LOMN-Beta}"
# Use Wine's builtin d3d8/ddraw: the bundled dgVoodoo wrapper crashes under Wine when the front end
# initialises (on wined3d, DXVK and D3DMetal alike). Set WINEDLLOVERRIDES="d3d8,ddraw,d3dimm=n,b" to try it anyway.
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-d3d8,ddraw,d3dimm=b}"

for app in "$CROSSOVER_APP" "$HOME/Applications/CrossOver.app" "/Applications/CrossOver.app"; do
	if [ -n "$app" ] && [ -x "$app/Contents/SharedSupport/CrossOver/bin/wine" ]; then
		CXBIN="$app/Contents/SharedSupport/CrossOver/bin"
		if [ ! -d "$HOME/Library/Application Support/CrossOver/Bottles/$BOTTLE" ]; then
			echo "Creating CrossOver bottle '$BOTTLE'..."
			"$CXBIN/cxbottle" --bottle "$BOTTLE" --create --template win10_64
		fi
		# CrossOver ignores WINEDLLOVERRIDES, it needs --dll
		exec "$CXBIN/wine" --bottle "$BOTTLE" --dll "$WINEDLLOVERRIDES" --workdir "$GAME_DIR" "$GAME_DIR/LEGOBionicle.exe" "$@"
	fi
done

WINE="$(command -v wine || command -v wine64 || true)"
if [ -z "$WINE" ]; then
	echo "No CrossOver or Wine found. Install CrossOver, or Wine (e.g. 'brew install --cask --no-quarantine gcenx/wine/wine-crossover')." >&2
	exit 1
fi
export WINEPREFIX="${WINEPREFIX:-$GAME_DIR/.wineprefix}"
exec "$WINE" "$GAME_DIR/LEGOBionicle.exe" "$@"
