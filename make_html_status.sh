#!/bin/bash
# Move to script directory.
cd "${0%/*}" &&
# Function for turning ls output to HTML.
ls_output_to_html () {
    # Initializing
    html=""
    dir=$1
    tab=$2
    is_output=$3
    # Reading output line by line.
    while read line
    do
        # Readling filesize and path from the line.
        array=( $line )
        filesize=${array[0]}
        unset array[0]
        filepath=${array[@]}
        filename=$(basename -- "$filepath")
        
        # Add filesize and filename to html.
        part="$filesize: $filename"
        # If empty just initialize.
        if [ -z "$html" ]
        then
            html="$tab$part"
        # Otherwise append with linebreak.
        else
            html="$html<br>$tab$part"
        fi

        # Add last line of the log.
        # Only if is output files.
        if [ "$is_output" = "true" ]; then
            # Only if there is a log file.
            log_path="./log/$filename.log"
            if [ -f "$log_path" ]; then
                # Get last row of the log file.
                last_row=`cat "$log_path" | tr '\r' '\n' | tail -n1`
                # Parses done time from last log row.
                done_time=`echo "$last_row" | python ./add_to_time.py`
                # And if it can be parsed add it to new line.
                if [ ! -z "$done_time" ]
                then
                    last_row="$last_row<br>$tab$tab => $done_time"
                fi
                # Append last row to HTML as a new line.
                html="$html<br>$tab$tab$last_row"
            fi
        fi
    done <<< "$(echo -e "$dir")"
    # Echo HTML-output.
    echo "$html"
}

# Outputing proccess statuses as a HTML.
running_html () {
    pid=`pgrep $1 | tail -1`
    if [[ $pid -gt 0 ]]
    then
        time=`ps -p $pid -o etime=`
        html="$3<span style='background-color: green' >$2 ($time)</span>"
    else
        html="$3<span style='background-color: red' >$2</span>"
    fi
    echo "$html"
}

# Tab charather.
TAB="&nbsp;&nbsp;"
# Get HTML-status data from input files.
LS_OUTPUT=`find ./input -type f -name "*.mkv" -exec ls -sh {} +`
INPUT_FILES=`ls_output_to_html "$LS_OUTPUT" "$TAB" false`
# Get HTML-status data from output files.
LS_OUTPUT=`find ./output -type f -name "*.mkv" -exec ls -sh {} +`
OUTPUT_FILES=`ls_output_to_html "$LS_OUTPUT" "$TAB" true`
# Read current time.
DATE=`date '+%Y-%m-%d %H:%M:%S'`
# Read current HTML-file.
HTML_FILE_PATH="./www/status.html"
if [ -r "$HTML_FILE_PATH" ]
then
    CURR_HTML=`cat "$HTML_FILE_PATH"`
else
    CURR_HTML=""
fi
# Get proccess status as a HTML
RUNNING=`running_html 'encode.sh' 'ENCODING' "$TAB"`
# Append newest status to the HTML-file.
cat <<EOT > "$HTML_FILE_PATH"
DATE:<br>
${TAB}${DATE}<br>
INPUT:<br>
${INPUT_FILES}<br>
OUTPUT:<br>
${OUTPUT_FILES}<br>
PROCESSES:<br>
${RUNNING}<br>
--------------------------------------------------------------------<br>
${CURR_HTML}
EOT
