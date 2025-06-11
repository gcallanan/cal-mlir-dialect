#!/bin/bash
set -e

rm -f output.txt

echo "Executing Program"
echo

./main_executable > output_from_qrd_program.txt

echo "Program Executed. Output:"
cat output_from_qrd_program.txt

python3 error_checker.py -f output_from_qrd_program.txt

