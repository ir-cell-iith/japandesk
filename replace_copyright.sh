#!/bin/bash


full='Copyright © 2024 Japan-Desk, IITH, Designed by <a href="https://webcovertech.com/" target="_blank">WebCover Infotech</a>'
short='Copyright © 2024 Japan-Desk, IITH'

if [ "$1" == "--revert" ]; then
    echo "Reverting to full version..."
    find . -type f -name "*.html" -exec sed -i "s|$short|$full|g" {} \;
    echo "Done: full version applied."
else
    echo "Applying short version..."
    find . -type f -name "*.html" -exec sed -i "s|$full|$short|g" {} \;
    echo "Done: short version applied."
fi

