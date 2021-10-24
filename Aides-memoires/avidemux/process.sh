#!/usr/bin/bash

INPUT_VIDEOS_PATH="/path/to/input/videos/files"
OUTPUT_VIDEOS_PATH="/path/to/output/videos/files"
PROJECT_SCRIPT="/path/to/script.py"

RM="$(which rm)"
MKDIR="$(which mkdir)"
BASENAME="$(which basename)"
AVIDEMUX_CLI="$(which avidemux3_cli)"

${MKDIR} -p "${OUTPUT_VIDEOS_PATH}"

for file in "${INPUT_VIDEOS_PATH}"/*
do
    OUTPUT_FILENAME=${OUTPUT_VIDEOS_PATH}/$(${BASENAME} "${file%.*}").mkv
    ${AVIDEMUX_CLI} --load "${file}" --run "${PROJECT_SCRIPT}" --save "${OUTPUT_FILENAME}" --quit
    ${RM} -f *.idx2
done

exit 0
