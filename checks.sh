#! /bin/sh
# arguments:
# 1. a relative path to a directory
# 2. flag to flip exit codes for success and failure (used in testing)
# 3. flag to ignore whitespace when diffing

if [ -z "$2" ] || [ "$2" == "0" ] ; then
    FAILURE_EXPECTED=0
    FAILURE_CODE=1
    SUCCESS_CODE=0
elif [ "$2" == "1" ] ; then
    echo "Reversing the definition of failure and success"
    FAILURE_EXPECTED=1
    FAILURE_CODE=0
    SUCCESS_CODE=1
else
    echo "Second input argument should be empty, 0, or 1. Aborting."
    exit 1;
fi

# If the user has provided a first input argument, interpret
# it as a relative path to a directory, and change into it
if [ -n "$1" ] ; then
    cd $1 || exit ${FAILURE_CODE}
    echo "Changed directory into $1"
fi

if [ "$3" == "0" ] ; then
    echo "Not ignoring the whitespace when diff'ing"
    DIFF_IGNORE_WHITESPACE=0
elif [ -z "$3" ] || [ "$3" == "1" ] ; then
    DIFF_IGNORE_WHITESPACE=1
else
    echo "Third input argument should be empty, 0, or 1. Aborting."
    exit 1;
fi


echo "Using cffconvert version $(cffconvert --version)."

# check if CITATION.cff exists
if [ -f "CITATION.cff" ]; then
    echo "(1/6) CITATION.cff file exists" ;
else
    echo "(1/6) CITATION.cff file missing. You can use https://bit.ly/cffinit to create one. Aborting.";
    exit ${FAILURE_CODE};
fi


# check if CITATION.cff is valid YAML
echo "(2/6) Check if CITATION.cff is valid YAML -- Unimplemented"


if $(cffconvert --validate) ; then
    echo "(3/6) CITATION.cff is valid CFF.";
else
    cffconvert --validate
    echo "(3/6) Warning: CITATION.cff is invalid CFF.";
fi


# check if .zenodo.json exists
if [ -f ".zenodo.json" ]; then
    echo "(4/6) .zenodo.json file exists" ;
else
    echo "(4/6) .zenodo.json file missing.";
    echo "Expected a .zenodo.json file with the following content..."
    cffconvert --outputformat zenodo --ignore-suspect-keys
    echo "...Aborting."
    exit ${FAILURE_CODE};
fi


# check if .zenodo.json is valid JSON
echo "(5/6) Check if .zenodo.json is valid JSON -- Unimplemented"


# check if CITATION.cff and .zenodo.json are equivalent
TMPFILE=$(mktemp .zenodo.json.XXXXXXXXXX)
cffconvert --outputformat zenodo --ignore-suspect-keys > ${TMPFILE}

if [ "${DIFF_IGNORE_WHITESPACE}" -eq "0" ] ; then
    if [ -z "$(diff .zenodo.json ${TMPFILE})" ] ; then
        echo "(6/6) CITATION.cff and .zenodo.json are equivalent.";
    else
        echo "I expected .zenodo.json to have the following content..."
        cat ${TMPFILE}
        echo "...but I found:"
        cat .zenodo.json
        echo "... with diff:"
        diff .zenodo.json ${TMPFILE}
        echo "(6/6) CITATION.cff and .zenodo.json are not equivalent. Aborting.";
        exit ${FAILURE_CODE};
    fi
else
    if [ -z "$(diff --ignore-all-space .zenodo.json ${TMPFILE})" ] ; then
        echo "(6/6) CITATION.cff and .zenodo.json are equivalent when ignoring whitespace.";
    else
        echo "I expected .zenodo.json to have the following content..."
        cat ${TMPFILE}
        echo "...but I found:"
        cat .zenodo.json
        echo "... with diff (ignoring whitespace):"
        diff --ignore-all-space .zenodo.json ${TMPFILE}
        echo "(6/6) CITATION.cff and .zenodo.json are not equivalent. Aborting.";
        exit ${FAILURE_CODE};
    fi
fi

exit ${SUCCESS_CODE};
