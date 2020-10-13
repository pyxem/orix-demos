#!/bin/bash

# Notes:
# * Visual Studio Code doesn't write some symbols to the .ipynb file the same way that Jupyter Notebook does, making some
#   cell output comparisons fail.

# Add number prefix to this list if the notebook is to be tested with
# $ pytest --nbval notebook.ipynb
declare -a NOTEBOOKS=("04")

# Assumes notebooks are located in the same directory as this file
DIR=${PWD}/

FILE_PATTERN="*.ipynb"
FILES=($DIR$FILE_PATTERN)
for FILE in "${FILES[@]}"; do
    NUMBER="${FILE%-*}"
    NUMBER="${NUMBER:(-3)}"
    if [[ " ${NOTEBOOKS[@]} " == *${NUMBER}* ]]; then
        pytest -v --nbval --current-env "${FILE}"
    fi
done
