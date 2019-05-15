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
# Loop through all .mkv files inside input directory recurcively. 
find "$INPUT_DIR" -name "*.mkv" -type f | while read filePath; do
    # Make all the paths for file.
    dir=$(dirname -- "$filePath") &&
    filename=$(basename -- "$filePath") &&
    presetPath="$dir/$PRESET_FILENAME" &&
    logPath="$LOG_DIR$filename.log" &&
    donePath="$DONE_DIR$filename" &&
    outputPath="$OUTPUT_DIR$filename" &&
    echo $presetPath &&
    echo $filePath &&
    echo $logPath &&
    echo $donePath &&
    echo $outputPath &&
    # Run HandBreak command.
    flatpak run --command=HandBrakeCLI fr.handbrake.ghb --preset-import-file "$presetPath" -i "$filePath" -o "$outputPath" 2>&1 | tee "$logPath" &&
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
    exit `./encode.sh`
# If there were no files just exit.
else
    exit 0
fi