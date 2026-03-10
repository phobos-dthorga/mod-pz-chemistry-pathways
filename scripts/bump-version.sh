#!/bin/bash
# bump-version.sh — Update PCP version in all 5 locations.
# Usage: ./scripts/bump-version.sh 1.3.0

set -e

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.3.0"
    exit 1
fi

if ! echo "$VERSION" | grep -qP '^\d+\.\d+\.\d+$'; then
    echo "Error: Version must be in X.Y.Z format (got: $VERSION)"
    exit 1
fi

echo "Bumping PCP to $VERSION ..."

# 1. mod.info (root)
OLD=$(grep -oP 'modversion=\K[0-9]+\.[0-9]+\.[0-9]+' mod.info)
sed -i "s/modversion=[0-9]*\.[0-9]*\.[0-9]*/modversion=$VERSION/" mod.info
echo "  mod.info (root): $OLD -> $VERSION"

# 2. 42.14/mod.info
OLD=$(grep -oP 'modversion=\K[0-9]+\.[0-9]+\.[0-9]+' 42.14/mod.info)
sed -i "s/modversion=[0-9]*\.[0-9]*\.[0-9]*/modversion=$VERSION/" 42.14/mod.info
echo "  42.14/mod.info: $OLD -> $VERSION"

# 3. 42.15/mod.info
OLD=$(grep -oP 'modversion=\K[0-9]+\.[0-9]+\.[0-9]+' 42.15/mod.info)
sed -i "s/modversion=[0-9]*\.[0-9]*\.[0-9]*/modversion=$VERSION/" 42.15/mod.info
echo "  42.15/mod.info: $OLD -> $VERSION"

# 4. PCP_ChangelogPopup.lua PCP_VERSION
OLD=$(grep -oP 'local PCP_VERSION\s*=\s*"\K[0-9]+\.[0-9]+\.[0-9]+' common/media/lua/client/PCP_ChangelogPopup.lua)
sed -i "s/local PCP_VERSION = \"[0-9]*\.[0-9]*\.[0-9]*/local PCP_VERSION = \"$VERSION/" common/media/lua/client/PCP_ChangelogPopup.lua
echo "  PCP_ChangelogPopup.lua: $OLD -> $VERSION"

# 5. PCP_MigrationSystem.lua MOD_VERSION
OLD=$(grep -oP 'local MOD_VERSION\s*=\s*"\K[0-9]+\.[0-9]+\.[0-9]+' common/media/lua/server/PCP_MigrationSystem.lua)
sed -i "s/local MOD_VERSION = \"[0-9]*\.[0-9]*\.[0-9]*/local MOD_VERSION = \"$VERSION/" common/media/lua/server/PCP_MigrationSystem.lua
echo "  PCP_MigrationSystem.lua: $OLD -> $VERSION"

echo "Done. Verify with:"
echo "  grep -n 'modversion' mod.info 42.14/mod.info 42.15/mod.info"
echo "  grep -n 'PCP_VERSION\|MOD_VERSION' common/media/lua/client/PCP_ChangelogPopup.lua common/media/lua/server/PCP_MigrationSystem.lua"
