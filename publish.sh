#!/bin/bash

# ============================
# Website Publisher
# ============================

LOCAL_DIR="."
REMOTE_DIR="public/"

GREEN='\033[0;32m'
BLUE='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo
echo "========================================"
echo "      Website Publisher v1.0"
echo "========================================"
echo

echo -e "${BLUE}[1/4]${NC} Checking local folder..."

if [ ! -d "$LOCAL_DIR" ]; then
    echo -e "${RED}✗ Folder '$LOCAL_DIR' not found.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Local folder found${NC}"
echo

echo -e "${BLUE}[2/4]${NC} Connecting to server..."

START=$(date +%s)

lftp sftp://japandesk <<EOF | while IFS= read -r line
set cmd:trace off
set xfer:clobber on
set ssl:verify-certificate no
set net:max-retries 2
set net:timeout 20

lcd $(pwd)

mirror -R \
    --verbose=3 \
    --delete \
    --only-newer \
    --parallel=8 \
    --exclude "^\.git($|/)" \
    --exclude "^\.github($|/)" \
    --exclude "^\.vscode($|/)" \
    --exclude "^\.jekyll-cache($|/)" \
    --exclude "^\.sass-cache($|/)" \
    --exclude "^node_modules($|/)" \
    --exclude "^vendor($|/)" \
    --exclude "^publish\.sh$" \
    --exclude "^README.*" \
    --exclude "^Gemfile.*" \
    --exclude "^\.DS_Store$" \
    "$LOCAL_DIR" "$REMOTE_DIR"

bye
EOF

do
    case "$line" in
        *Transferring*)
            FILE=$(echo "$line" | sed 's/.*Transferring //')
            echo -e "${YELLOW}↑ Uploading:${NC} $FILE"
            ;;
        *Making\ directory*)
            echo -e "${BLUE}📁 Creating:${NC} ${line#*Making directory }"
            ;;
        *Removing*)
            echo -e "${RED}🗑 Removing:${NC} ${line#*Removing }"
            ;;
        *)
            echo "$line"
            ;;
    esac
done

STATUS=${PIPESTATUS[0]}

if [ $STATUS -ne 0 ]; then
    echo
    echo -e "${RED}✗ Upload failed.${NC}"
    exit 1
fi

END=$(date +%s)
TIME=$((END-START))

echo
echo "========================================"
echo -e "${GREEN}✓ Website Published Successfully${NC}"
echo "Time Taken : ${TIME} seconds"
echo "Server     : japandesk"
echo "========================================"
echo
