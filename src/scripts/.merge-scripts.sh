#!/bin/bash
# some cleanup
rm -f functions names openshift-install-wrapper
for _file in *; do
  echo - Merging ${_file}

  # Extract data from the file
  _name=$( grep -Po "^# script name: \K(.*)$" ${_file} )
  _description=$( grep -Po "^# script description: \K(.*)$" ${_file} )

  # Use the filename if there's no name
  if [ -z "${_name}" ]; then
    echo "  Warning: Emtpy name. Using filename as customization name"
    _name=${_file}
  fi

  # Extract the main function and rename it properly and add it to the functions file
  sed -n -e '/# start main/,/# end main/{ /^#.*/d;p }' ${_file} | sed "s/^main/${_name}/g" >> functions
  echo >> functions

  # Add the name and description (if any) in the names file
  if [ -z "${_description}" ]; then
    echo "  Warning: Empty description"
    echo -e "  - ${_name}" >> names
  else
    echo -e "  - ${_name} - ${_description}" >> names
  fi
done

# replace the custom scripts marker with the functions file content
sed -e '/\#__CUSTOM_SCRIPTS__/{r functions' -e 'd}' ../../openshift-install-wrapper > openshift-install-wrapper

# replace the custom scripts names marker with the names file content
sed -e '/\#__CUSTOM_SCRIPTS_NAMES__/{r names' -e 'd}' -i openshift-install-wrapper

# replace original wrapper with included content
mv -f openshift-install-wrapper ../../openshift-install-wrapper
