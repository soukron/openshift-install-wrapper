#!/bin/bash

output_file="../30_templates.sh"
echo "# install-config templates" > "$output_file"

for file in $(find . -type f -name "*.yaml"); do
    platform=$(basename $(dirname "$file"))
    filename=$(basename "$file" .yaml)
    key="${platform}-${filename}"
    
    base64_content=$(base64 -w 0 "$file")
    echo "INSTALLTEMPLATES[$key]=\"$base64_content\"" >> "$output_file"
done
echo "" >> "$output_file"