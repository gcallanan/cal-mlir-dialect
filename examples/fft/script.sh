set -e

#cd ../..

#node bin/cli.js generate examples/fft/Top.cal

#cd -

cal-opt --cal-network-elab="top=fft__Top" FFT_Top_32768.mlir > FFT_Flattened.mlir

sed -i '/^[[:space:]]*in_names \[.*\][[:space:]]*$/d; /^[[:space:]]*out_names \[.*\][[:space:]]*$/d' FFT_Flattened.mlir

sed -i 's/\(cal\.create_instance[^"]*"[^"]*"\)\s*()/\1 device_affinity="cpu0" ()/g' FFT_Flattened.mlir

#sed -i 's/ {cal\.name = "[^"]*"}//g' FFT_Flattened.mlir

#sed -i 's/cal\.network @/cal.network \/\/ @/g' FFT_Flattened.mlir



cal-opt FFT_Flattened.mlir --lower-cal-to-llvm="multithread-cal-actors" > lowered.mlir
cal-translate --mlir-to-llvmir lowered.mlir -o lowered.ll
clang -O0 lowered.ll -o multithreaded.out -L"../../llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread -lm

time ./multithreaded.out

#echo "Running the generated code..."

#mlir-runner --entry-point-result=i32 lowered.mlir