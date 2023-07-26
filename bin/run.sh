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

timeout_duration=5

redirect_file=$(mktemp)
pyret_command="pyret -q ${relative_test_file}"
timeout $timeout_duration $pyret_command &> $redirect_file

timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    rm "$redirect_file"
    redirect_file=$(mktemp)
    timeout $timeout_duration stdbuf -oL -eL $pyret_command &> $redirect_file
    timeout_status=$?
fi

if [ $timeout_status -eq 124 ]; then
    status="error"
    message="Test runner timed out"
    jq -n --arg output "${message}" --arg status "${status}" '{version: 1, status: $status, message: $output}' > ${results_file}
else
    # Run the tests for the provided implementation file and redirect stdout and
    # stderr to capture it
    test_output=$(cat "$redirect_file")
    rm "$redirect_file"
    # Write the results.json file based on the exit code of the command that was
    # just executed that tested the implementation file

    # pyret reports 0 for a syntax error or empty file
    success=$(echo "${test_output}" | grep -c -E 'Looks shipshape, all [0-9]+ test[s]* passed')
    error=$(echo "${test_output}" | grep -c -E "Pyret didn't understand your program")
    if [[ $success -gt 0 ]]; then
        jq -n '{version: 1, status: "pass"}' > ${results_file}
    else
        # OPTIONAL: Sanitize the output
        # In some cases, the test output might be overly verbose, in which case stripping
        # the unneeded information can be very helpful to the student
        # sanitized_test_output=$(printf "${test_output}" | sed -n '/Test results:/,$p')

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
fi
