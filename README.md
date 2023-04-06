# Push_swap_tester
Simple input, output and memory leak tester for 42 project push_swap
#Bash Script for Testing Push_Swap
This repository contains a bash script for testing a push_swap program, in combination with a checker file.
Include it in your Makefile for combining with multiple tests.

# Prerequisites
+ Bash shell
+ Push_Swap program
+ Checker program

# Usage
Run the tester.sh script with the following command:

```
./test_push_swap.sh <min> <max> <count> [<flags>] [<type>]
```
* 'min': the minimum value for the random number generator.
* 'max': the maximum value for the random number generator.
* 'count': the number of random numbers to generate.
* 'flags' (optional): the test flags to use:
    - 1: add a non-valid character.
    - 2: add a number outside of the range.
    - 3: add a duplicate number.
* 'type' (optional): the input type to use:
    - 1: input as a single string.
    - 2: input as two strings.

For example, to test push_swap with a range of -100 to 100, generating 500 random numbers, and adding a non-valid character flag, you would use the following command:

```
./test_push_swap.sh -100 100 500 1
```
Output
The script generates random numbers within the given range and tests the push_swap program with them. The output displays whether the push_swap program output is correct or not.

If the output desired and there are no memory-leaks the checker program returns "OK" otherwise it will show "KO"

```
Output: OK
Valgrind: OK
```

# Note
This bash script only works in combination with a checker file. Please ensure that the checker program is in the same directory as the push_swap program before running the script.

