#!/bin/sh

python=`which python3`

if test "x$python" = "x"; then
    echo "Note: falling back to python from python3"
    python="python"
fi


# Check to see if ivpm is already installed
$python -m ivpm --help >/dev/null 2>&1

# Not installed, so clone a local copy
if test $? -ne 0; then
    echo "Note: ivpm is not installed -- fetching ..."
    git clone https://github.com/mballance/ivpm .ivpm
    export PYTHONPATH=`pwd`/.ivpm/src
else
    echo "Note: ivpm is already installed"
fi

# Fetch dependencies and setup virtual environment
$python -m ivpm update

