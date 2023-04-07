#!/bin/bash

# Parse command line arguments
if ! [ -e ./push_swap ]; then
  echo "Error: ./push_swap file not found"
  echo "Push_swap_tester
Usage:
      $0 <min_value> <max_value> <numbers_to_generate>
"
fi

if ! [ -e ./checker_linux ]; then
  echo "Error: ./checker_linux file not found"
  echo "Push_swap_tester
Usage:
      $0 <min_value> <max_value> <numbers_to_generate>
"
fi

min=$((10#${1:-1}))
max=$((10#${2:-1000}))
count=$((10#${3:-10}))

echo "Min: $min" "Max: $max" "Count: $count"

INT_MIN=-2147483648
INT_MAX=2147483647

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# Check range
if [ "$min" -gt "$max" ]; then
    echo "Error: min is greater than max"
    exit 1
fi

# Generate random numbers
numbers=()
output_desired=()
for ((i=0; i<count; i++)); do
    num=$((RANDOM % (max - min + 1) + min))
    while [[ "${numbers[@]}" =~ "$num" ]]; do
        num=$((RANDOM % (max - min + 1) + min))
    done
    numbers+=("$num")
done
echo ${numbers[@]}
original_numbers=("${numbers[@]}")

function run_test() {
    input=("$1")
    output_desired="$2"
    echo -e "${YELLOW}Testing: $3${RESET}"
    echo "Numbers:" ${input[@]}
    output_new="$(echo -e "$input" | ./push_swap "$input"  | ./checker_linux "$input" 2>&1)"

    # Check output
    if [ "$output_new" = "$output_desired" -o "$output_new" = "OK" ]; then
        echo -e "\t\t\t\tOutput:\t\t"${GREEN}"OK"${RESET}
    else
        echo -e "\t\t\t\tOutput:\t\t"${RED}"KO"${RESET}
    fi

    # Check Valgrind
    valgrind_output="$(echo -e "$input" | valgrind --leak-check=full --error-exitcode=1 ./push_swap 2>&1)"
    if echo "$valgrind_output" | grep -q "in use at exit: 0 bytes"; then
        echo -e "\t\t\t\tValgrind:\t"${GREEN}"OK"${RESET}
    else
        echo -e "\t\t\t\tValgrind:\t"${RED}"KO"${RESET}
        echo "$valgrind_output" | grep --color -A2 "in use at exit"
    fi
}

# Add non-valid character
index=$((RANDOM % count))
numbers[$index]='u'
output_desired="Error"
run_test "${numbers[*]}" "$output_desired" "non-valid character"
numbers=("${original_numbers[@]}")

# Add number outside range
index=$((RANDOM % count))
num=$((RANDOM % 2))
if [ $num -eq 0 ]; then
    num=$((INT_MAX + 1 + RANDOM))
else
    num=$((INT_MIN - 1 - RANDOM))
fi
numbers[$index]=$num
output_desired="Error"
run_test "${numbers[*]}" "$output_desired" "number outside range"
numbers=("${original_numbers[@]}")

# Add duplicate number
index1=$((RANDOM % count))
index2=$((RANDOM % count))
numbers[$index1]=${numbers[$index2]}
output_desired="Error"
run_test "${numbers[*]}" "$output_desired" "duplicate number"
numbers=("${original_numbers[@]}")

# Adjust input (multiple arguments, string or mixed)
group1=($(echo "${numbers[@]}" | cut -d' ' -f -$((count/2))))
group2=($(echo "${numbers[@]}" | cut -d' ' -f $(((count/2)+1))-))
output_desired="Error"
run_test "${group1[*]} ${group2[*]}" "$output_desired" "multiple arguments"

echo $(valgrind --log-file=testfile ./push_swap "${group1[@]}" "${group2[*]}" > /dev/null)
output_new=$(./push_swap "${group1[@]}" "${group2[*]}" | ./checker "${group1[@]}" "${group2[*]}" 2>&1)
run_test "${group1[*]} ${group2[*]}" "$output_desired" "multiple arguments"

echo -e "\t\t\t " $(valgrind --log-file=testfile ./push_swap "${numbers[*]}" > /dev/null)
output_new=$(./push_swap "${numbers[*]}" | ./checker "${numbers[*]}" 2>&1)
run_test "${numbers[*]}" "$output_desired" "string"

echo -e "\t\t\t " $(valgrind --log-file=testfile ./push_swap "${numbers[@]}" > /dev/null)
output_new=$(./push_swap "${numbers[@]}" | ./checker "${numbers[@]}" 2>&1)
run_test "${numbers[*]}" "$output_desired" "mixed"