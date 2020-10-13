#!/bin/bash

# Add number prefix to this list if the notebook is to be tested with
# $ pytest --nbval notebook.ipynb
declare -a NOTEBOOKS=("04")

# Assumes notebooks are located in the same directory as this file
DIR=${PWD}/

FILE_PATTERN="*.ipynb"
FILES=($DIR$FILE_PATTERN)
for FILE in "${FILES[@]}"; do
    echo ${FILE}
    NUMBER="${FILE%-*}"
    NUMBER="${NUMBER:(-3)}"
    if [[ " ${NOTEBOOKS[@]} " == *${NUMBER}* ]]; then
        pytest --nbval "${FILE}"
    fi
done
