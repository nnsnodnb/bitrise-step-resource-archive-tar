#!/bin/bash
set -ex

if [ -z "$archive_url" ]; then
  echo " [!] archive_url is not provided - required!"
  exit 1
fi;

if [ -z "$extract_to_path" ]; then
  echo " [!] extract_to_path is not provided - required!"
  exit 1
fi;

if [ "$archive_file_extension" = ".tar.gz" ]; then
  options="-zxf"
elif [ "$archive_file_extension" = ".tar.bz2" ]; then
  options="-jxf"
elif [ "$archive_file_extension" = ".tar.xz" ]; then
  options="-Jxf"
elif [ "$archive_file_extension" = ".tar" ]; then
  options="-xf"
else
  echo " [!] archive_file_extension is not a selectable value!"
  exit 1
fi;

if [ "verbose_log" = "yes" ]; then
  options+="v"
fi;

echo "------------------------------------------------"
echo " Inputs:"
echo "  archive_url: $archive_url"
echo "  extract_to_path: $extract_to_path"
echo "  archive_file_extension: $archive_file_extension"
echo "------------------------------------------------"

# --- Preparations
mkdir {"downloads","unarchived"}

# --- Download
curl -Lfo "downloads/resource$archive_file_extension" "$archive_url"
if [ -e "downloads/resource$archive_file_extension" ]; then
  echo " (i) Download OK (not an error response)"
else
  echo " [!] Download failed"
  exit 1
fi;

# --- Unarchive
tar "$options" "downloads/resource$archive_file_extension" -C "unarchived/"
unarchive_result=$?
if [ $unarchive_result -eq 0 ]; then
  echo " (i) Unarchive OK"
else
  echo " [!] Unarchive failed (error code: $unarchive_result)"
  exit $unarchive_result
fi;

# --- Prepare the target path
if [ ! -d "$extract_to_path" ]; then
  echo " (i) extract_to_path directory doesn't exist - creating it..."
  mkdir -p "$extract_to_path"
  prepare_result=$?
  if [ $prepare_result -eq 0 ]; then
    echo " (i) Directory created"
  else
    echo " [!] Could not create directory! (error code: $prepare_result)"
    exit $prepare_result
  fi;
fi;

# --- Copy to the required location
cp -r unarchived/ "$extract_to_path"
copy_result=$?
if [ $copy_result -eq 0 ]; then
  echo " (i) Copy OK"
else
  echo " [!] Copy failed! (error code: $copy_result)"
fi;

exit 0