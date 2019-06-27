#!/bin/bash
# Move to script directory.
cd "${0%/*}" &&
# Initialize constants.
INPUT_DIR="./input/" &&
OUTPUT_DIR="./output/" &&
DONE_DIR="./done/" &&
LOG_DIR="./log/" &&
PRESET_FILENAME="preset.json" &&
# Make directories.
mkdir -p $INPUT_DIR &&
mkdir -p $OUTPUT_DIR &&
mkdir -p $DONE_DIR &&
mkdir -p $LOG_DIR &&
# Initialize file counter.
counter=0 &&
echo "Starting..."
# Loop through all .mkv files inside input directory recurcively. 
shopt -s globstar
for filePath in $INPUT_DIR**/*.mkv; do # Whitespace-safe and recursive
    # If empty then just continue.
    if [ -z "$filePath" ]
    then
       continue
    fi
    # Make all the paths for file.
    dir=$(dirname -- "$filePath") &&
    filename=$(basename -- "$filePath") &&
    presetPath="$dir/$PRESET_FILENAME" &&
    logPath="$LOG_DIR$filename.log" &&
    donePath="$DONE_DIR$filename" &&
    outputPath="$OUTPUT_DIR$filename" &&
    if [ -r "$outputPath" ]
    then
        echo "Already file at '$outputPath'!";
        exit;
    fi
    # Run HandBreak command.
    set -o pipefail &&
    echo "Encoding $filename..." &&
    HandBrakeCLI --preset-import-file "$presetPath" -i "$filePath" -o "$outputPath" 2>&1 | tee "$logPath"
    if [ $? -ne 0 ]; then
        set +o pipefail
        echo "Encoding failed!";
        exit;
    fi
    echo "Cleaning..." &&
    set +o pipefail &&
    # Move finnished file to output dir.
    mv "$filePath" "$donePath" &&
    # Remove log file.
    rm -f "$logPath" &&
    # Increment the counter.
    ((counter++))
done 
# If there where some files then try to run again, because there may be new files.
if [ $counter -gt 0 ]
then
    echo "Re-scanning..." &&
    ./encode.sh &&
    exit 0
# If there were no files just exit.
else
    echo "All done!" &&
    exit 0
fi
