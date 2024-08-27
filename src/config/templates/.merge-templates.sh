#!/bin/bash

output_file="../30_templates.sh"
echo "# install-config templates" > "$output_file"

for platform_dir in $(find . -mindepth 1 -maxdepth 1 -type d); do
  platform=$(basename "$platform_dir")
  if [[ ! -f "$platform_dir/default.yaml" ]]; then
    echo "Error: No default.yaml template for $platform platform. Fix the templates and try again."
    exit
  fi
done

for file in $(find . -type f -name "*.yaml"); do
  platform=$(basename $(dirname "$file"))
  filename=$(basename "$file" .yaml)
  key="${platform}-${filename}"
    
  base64_content=$(base64 -w 0 "$file")
  echo "INSTALLTEMPLATES[$key]=\"$base64_content\"" >> "$output_file"
done
echo "" >> "$output_file"