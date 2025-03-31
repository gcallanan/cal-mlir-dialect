// RUN: cal-opt --show-dialects
module {
  func.func @main() -> i32 {
    %in0,%out0 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %constant672 = arith.constant 196 : i32 
    fifo.push(%in0: !fifo.input_port<i32>, %constant672: i32)
    %0 = fifo.pull(%out0: !fifo.output_port<i32>) : i32
    %constant17 = arith.constant 17 : i32
    %newResult = arith.addi %constant17, %0: i32
    fifo.push(%in0: !fifo.input_port<i32>, %newResult: i32)
    func.return %newResult : i32
  }
}
