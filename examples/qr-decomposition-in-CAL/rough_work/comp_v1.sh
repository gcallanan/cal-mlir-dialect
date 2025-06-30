pwd

rm -f temp0.txt temp1.txt temp2.txt temp3.txt temp4.txt temp5.txt temp6.txt temp7.txt

echo "Compiling to MLIR"

bash generate_mlir.sh

echo "Mlir Generated - Generating binaries now"

mlirBuild0Time=$( { /usr/bin/time -f "%e" bash create_binary_from_mlir.sh -O 0 ; } 2>&1)
echo "Building 0 Done: $mlirBuild0Time"
mlirRun0Time=$( { /usr/bin/time -f "%e" ./main_executable > temp0.txt ; } 2>&1)
echo "Running 0 Done: $mlirRun0Time"

mlirBuild1Time=$( { /usr/bin/time -f "%e" bash create_binary_from_mlir.sh -O 1 ; } 2>&1)
echo "Building 1 Done: $mlirBuild1Time"
mlirRun1Time=$( { /usr/bin/time -f "%e" ./main_executable > temp1.txt ; } 2>&1)
echo "Running 1 Done: $mlirRun1Time"

mlirBuild2Time=$( { /usr/bin/time -f "%e" bash create_binary_from_mlir.sh -O 2 ; } 2>&1)
echo "Building 2 Done: $mlirBuild2Time"
mlirRun2Time=$( { /usr/bin/time -f "%e" ./main_executable > temp2.txt ; } 2>&1)
echo "Running 2 Done: $mlirRun2Time"

mlirBuild3Time=$( { /usr/bin/time -f "%e" bash create_binary_from_mlir.sh -O 3 ; } 2>&1)
echo "Building 3 Done: $mlirBuild3Time"
mlirRun3Time=$( { /usr/bin/time -f "%e" ./main_executable > temp3.txt ; } 2>&1)
echo "Running 3 Done: $mlirRun3Time"

echo "Compiling to Multicore"

rm -rf myproject
streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top


echo "Multicore C++ Generated - Generating Binaries now"

rm -rf myproject/build/ && mkdir -p  myproject/build/ && cd myproject/build/
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O0" > /dev/null 2> /dev/null
/usr/bin/time -f "%e" cmake --build . -j24 > /dev/null 2>&1
#cppBuild0Time=$({ /usr/bin/time -f "%e" cmake --build . -j24 > /dev/null; } 2>&1)
echo "Building Cpp 0 Done: $cppBuild0Time"
cd ../.. && cp myproject/bin/Top main_executable
cppRun0Time=$( { /usr/bin/time -f "%e" ./main_executable > temp4.txt ; } 2>&1)
echo "Running Cpp 0 Done: $cppRun0Time"

rm -rf myproject/build/ && mkdir -p  myproject/build/ && cd myproject/build/
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O1" > /dev/null 2> /dev/null
/usr/bin/time -f "%e" cmake --build . -j24 > /dev/null 2>&1 ;
echo "Building Cpp 1 Done: $cppBuild1Time"
cd ../.. && cp myproject/bin/Top main_executable
cppRun1Time=$( { /usr/bin/time -f "%e" ./main_executable > temp5.txt ; } 2>&1)
echo "Running Cpp 1 Done: $cppRun1Time"

rm -rf myproject/build/ && mkdir -p  myproject/build/ && cd myproject/build/
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O2" > /dev/null 2> /dev/null
/usr/bin/time -f "%e" cmake --build . -j24 > /dev/null 2>&1
echo "Building Cpp 2 Done: $cppBuild2Time"
cd ../.. && cp myproject/bin/Top main_executable
cppRun2Time=$( { /usr/bin/time -f "%e" ./main_executable > temp6.txt ; } 2>&1)
echo "Running Cpp 2 Done: $cppRun2Time"

rm -rf myproject/build/ && mkdir -p  myproject/build/ && cd myproject/build/
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O3" > /dev/null 2> /dev/null
/usr/bin/time -f "%e" cmake --build . -j24 > /dev/null 2>&1
echo "Building Cpp 3 Done: $cppBuild0Time"
cd ../.. && cp myproject/bin/Top main_executable
cppRun3Time=$( { /usr/bin/time -f "%e" ./main_executable > temp7.txt ; } 2>&1)
echo "Running Cpp 3 Done: $cppRun3Time"

echo "Compiling with Tycho to C"

rm -rf myproject && mkdir myproject
tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top

echo "Multicore C Generated - Generating Binaries now"
cc myproject/*.c -O0 -o main_executable
echo "Building C 0 Done: $cBuild0Time"
cRun0Time=$( { /usr/bin/time -f "%e" ./main_executable > temp8.txt ; } 2>&1)
echo "Running C 0 Done: $cRun0Time"

cc myproject/*.c -O1 -o main_executable
echo "Building C 1 Done: $cBuild1Time"
cRun1Time=$( { /usr/bin/time -f "%e" ./main_executable > temp9.txt ; } 2>&1)
echo "Running C 1 Done: $cRun1Time"

cc myproject/*.c -O2 -o main_executable
echo "Building C 2 Done: $cBuild2Time"
cRun2Time=$( { /usr/bin/time -f "%e" ./main_executable > temp10.txt ; } 2>&1)
echo "Running C 2 Done: $cRun2Time"

cc myproject/*.c -O3 -o main_executable
echo "Building C 3 Done: $cBuild3Time"
cRun3Time=$( { /usr/bin/time -f "%e" ./main_executable > temp11.txt ; } 2>&1)
echo "Running C 3 Done: $cRun3Time"

echo "MLIR O1"
diff temp0.txt temp1.txt
echo
echo "MLIR O2"
diff temp0.txt temp2.txt
echo
echo "MLIR O3"
diff temp0.txt temp3.txt
echo


echo "OptimisationFlag,0,1,2,3"
echo "MlirCompilationTime,$mlirBuild0Time,$mlirBuild1Time,$mlirBuild2Time,$mlirBuild3Time"
echo "CppCompilationTime,$cppBuild0Time,$cppBuild1Time,$cppBuild2Time,$cppBuild3Time"
echo "MlirRunningTime,$mlirRun0Time,$mlirRun1Time,$mlirRun2Time,$mlirRun3Time"
echo "CppRunningTime,$cppRun0Time,$cppRun1Time,$cppRun2Time,$cppRun3Time"
echo "CRunningTime,$cRun0Time,$cRun1Time,$cRun2Time,$cRun3Time"


