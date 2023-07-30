#!/usr/bin/env sh

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: path to solution folder
# $3: path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug path/to/solution/folder/ path/to/output/directory/"
    exit 1
fi

slug="$1"
relative_solution_dir="$2"
output_dir=$(realpath "${3%/}")
relative_test_file="${relative_solution_dir}/${slug}-test.arr"
results_file="${output_dir}/results.json"

mkdir -p "${output_dir}"
echo "${slug}: testing..."

# Pyret seems to hang more often if I redirect stderr to stdout. 
redirect_file=$(mktemp)
pyret -q $relative_test_file &> $redirect_file
test_output=$(cat $redirect_file)
rm $redirect_file

# pyret reports 0 for a syntax error or empty file so we need to check the output closely
success=$(echo "${test_output}" | grep -c -E "Looks shipshape, (your|all [0-9]+) test[s]* passed")
error=$(echo "${test_output}" | grep -c -E "Pyret didn't understand your program")
if [[ $success -gt 0 ]]; then
    jq -n '{version: 1, status: "pass"}' > ${results_file}
else
    text_to_remove="file://$(realpath "${2%/}")/"

    sanitized_test_output=$(echo "${test_output}" | sed "s@${text_to_remove}@@g")
    sanitized_test_output=$(echo "${sanitized_test_output}" | sed '/./,$!d; s/^[[:space:]]*//; s/\n/ /g')
    status="fail"
    if [[ $error -gt 0 ]]; then
        status="error"
    fi

    # OPTIONAL: Manually add colors to the output to help scanning the output for errors
    # If the test output does not contain colors to help identify failing (or passing)
    # tests, it can be helpful to manually add colors to the output
    # colorized_test_output=$(echo "${test_output}" \
    #      | GREP_COLOR='01;31' grep --color=always -E -e '^(ERROR:.*|.*failed)$|$' \
    #      | GREP_COLOR='01;32' grep --color=always -E -e '^.*passed$|$')
    # jq -n --arg output "${test_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
    jq -n --arg output "${sanitized_test_output}" --arg status "${status}" '{version: 1, status: $status, message: $output}' > ${results_file}
fi

echo "${slug}: done"
