#!/bin/bash

# Parse command line arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <min> <max> <count> [<flags>] [<type>]"
    echo "Flags: 1 = add non-valid char, 2 = add number outside range, 3 = add duplicate"
	echo "Type: string = args as one string, mixed = args as string & individual"
    exit 1
fi

min=$1
max=$2
count=$3
flag=${4:-0}
typ=${5:-0}
INT_MIN=-2147483648
INT_MAX=2147483647

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

# Add non-valid character
if [ "$flag" -eq 1 ]; then
    index=$((RANDOM % count))
    numbers[$index]='u'
	output_desired="ERROR"
fi

# Add number outside range
if [ "$flag" -eq 2 ]; then
    index=$((RANDOM % count))
    num=$((RANDOM % 2))
    if [ $num -eq 0 ]; then
        num=$((INT_MAX + 1 + RANDOM))
    else
        num=$((INT_MIN - 1 - RANDOM))
    fi
    numbers[$index]=$num
	output_desired="ERROR"
fi

# Add duplicate number
if [ "$flag" -eq 3 ]; then
    index1=$((RANDOM % count))
    index2=$((RANDOM % count))
    numbers[$index1]=${numbers[$index2]}
	output_desired="ERROR"
fi

success="OK"
fail="KO"
error="Error"
# Print numbers and call cprogram
echo -e "\033[33mGenerated random numbers:\033[0m"
if [ "$typ" -eq 2 ]; then 
	group1=($(echo "${numbers[@]}" | cut -d' ' -f -$((count/2))))
	group2=($(echo "${numbers[@]}" | cut -d' ' -f $(((count/2)+1))-))
	output_desired="Error"
	echo -e "\033[33m"./push_swap "${group1[@]}" '"'"${group2[*]}"'"'"\033[0m"
	echo $(valgrind --log-file=testfile ./push_swap "${group1[@]}" "${group2[*]}")
	output_new=$(./push_swap "${group1[@]}" "${group2[*]}" | ./checker "${group1[@]}" "${group2[*]}" 2>&1)
	#Print Checks
	if [ "$output_new" = "$output_desired" ]; then
  		echo -e "Output:\t\t \033[32mOK\033[0m"
	else
  		echo -e "Output:\t\t \033[31mKO\033[0m"
	fi
	echo -e "Valgrind:\t" $(awk '/in use at exit: 0 bytes/{f=1; printf "\033[0;32mOK\033[0m\n"; exit} /in use at exit:/{f=1; printf "\033[0;31mKO\033[0m\n"; exit} END{if(!f) printf "\033[0;31mKO\033[0m\n"}' testfile)
	cat testfile | grep --color -A2 "in use at exit"
elif [ "$typ" -eq 1 ]; then 
	echo -e "\033[33m"./push_swap '"'"${numbers[*]}"'"'"\033[0m"
	echo $(valgrind --log-file=testfile ./push_swap "${numbers[*]}")
	output_new=$(./push_swap "${numbers[*]}" | ./checker "${numbers[*]}" 2>&1)
	#Print Checks
	if [ "$output_new" = "$success" ]; then
  		echo -e "Output:\t\t \033[32mOK\033[0m"
	elif [ "$output_new" = "$fail" ]; then
  		echo -e "Output:\t\t \033[31mKO\033[0m"
	elif [ "$output_new" = "$output_desired" ]; then
  		echo -e "Output:\t\t \033[31mOK\033[0m"
fi
	echo -e "Valgrind:\t" $(awk '/in use at exit: 0 bytes/{f=1; printf "\033[0;32mOK\033[0m\n"; exit} /in use at exit:/{f=1; printf "\033[0;31mKO\033[0m\n"; exit} END{if(!f) printf "\033[0;31mKO\033[0m\n"}' testfile)
	cat testfile | grep --color -A2 "in use at exit"
else 
	echo -e "\033[33m"./push_swap "${numbers[@]}""\033[0m"
	echo $(valgrind --log-file=testfile ./push_swap "${numbers[@]}")
	output_new=$(./push_swap "${numbers[@]}" | ./checker "${numbers[@]}" 2>&1)
	#Print Checks
	if [ "$output_new" = "$success" ]; then
  		echo -e "Output:\t\t \033[32mOK\033[0m"
	elif [ "$output_new" = "$fail" ]; then
  		echo -e "Output:\t\t \033[31mKO\033[0m"
	elif [ "$output_new" = "$output_desired" ]; then
  		echo -e "Output:\t\t \033[31mOK\033[0m"
	fi

	echo -e "Valgrind:\t" $(awk '/in use at exit: 0 bytes/{f=1; printf "\033[0;32mOK\033[0m\n"; exit} /in use at exit:/{f=1; printf "\033[0;31mKO\033[0m\n"; exit} END{if(!f) printf "\033[0;31mKO\033[0m\n"}' testfile)
	cat testfile | grep --color -A2 "in use at exit"
fi
