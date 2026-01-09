// RUN: cal-opt %s --convert-cal-to-func="actor-paritioning-mode=one-actor-per-thread" | FileCheck %s
module {
  cal.actor @src(%arg0: i32, %arg1: i32)
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %false = arith.constant false
    %true = arith.constant true
    %c100_i32 = arith.constant 100 : i32
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.execution_body {
      %1 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %2 = arith.cmpi slt, %1, %arg0 : i32
      %3 = scf.if %2 -> (i1) {
        %4 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %5 = arith.addi %4, %c1_i32 : i32
        cal.set(%0 : !cal.state_ref<i32>, %5 : i32)
        %6 = arith.muli %arg1, %c100_i32 : i32
        %7 = arith.addi %4, %6 : i32
        fifo.push(%arg2 : !fifo.input_port<i32>, %7 : i32)
        fifo.print("Src %d, pushed token: %d\0A\00", %arg1, %7) : (i32, i32)
        scf.yield %true : i1
      } else {
        scf.yield %false : i1
      }
      cal.action_done %3 : i1
    }
  }
  
  cal.actor @sink()
    ports_in (
      %arg0: !fifo.output_port<i32>
    )
  {
    %false = arith.constant false
    %true = arith.constant true
    cal.execution_body {
      %0 = scf.if %true -> (i1) {
        %1 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
        fifo.print("Popped Token: %d\0A\00", %1) : (i32)
        scf.yield %true : i1
      } else {
        scf.yield %false : i1
      }
      cal.action_done %0 : i1
    }
  }
  
  cal.actor @merge()
    ports_in (
      %arg0: !fifo.output_port<i32>, 
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %false = arith.constant false
    %true = arith.constant true
    cal.execution_body {
      %0 = scf.if %true -> (i1) {
        %1 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
        fifo.push(%arg2 : !fifo.input_port<i32>, %1 : i32)
        scf.yield %true : i1
      } else {
        %1 = scf.if %true -> (i1) {
          %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
          fifo.push(%arg2 : !fifo.input_port<i32>, %2 : i32)
          scf.yield %true : i1
        } else {
          scf.yield %false : i1
        }
        scf.yield %1 : i1
      }
      cal.action_done %0 : i1
    }
  }
  
  // CHECK: func.func @main() {
  // CHECK-DAG: %[[C50000_I32:.*]] = arith.constant 50000 : i32
  // CHECK-DAG: %[[TRUE:.*]] = arith.constant true
  // CHECK-DAG: %[[C48:.*]] = arith.constant 48 : index
  // CHECK-DAG: %[[C32:.*]] = arith.constant 32 : index
  // CHECK-DAG: %[[C16:.*]] = arith.constant 16 : index
  // CHECK-DAG: %[[C0:.*]] = arith.constant 0 : index
  // CHECK-DAG: %[[C0_I32:.*]] = arith.constant 0 : i32
  // CHECK-DAG: %[[C10_I32:.*]] = arith.constant 10 : i32
  // CHECK-DAG: %[[C1_I32:.*]] = arith.constant 1 : i32
  // CHECK-DAG: %[[C2_I32:.*]] = arith.constant 2 : i32
  
  cal.network {
    %c10_i32 = arith.constant 10 : i32
    %c1_i32 = arith.constant 1 : i32
    %c2_i32 = arith.constant 2 : i32
    %inputPort, %outputPort = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_0, %outputPort_1 = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_2, %outputPort_3 = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    // Create FIFO channels
    // CHECK: %[[INPUT_PORT:.*]], %[[OUTPUT_PORT:.*]] = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    // CHECK-NEXT: %[[INPUT_PORT_0:.*]], %[[OUTPUT_PORT_1:.*]] = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    // CHECK-NEXT: %[[INPUT_PORT_2:.*]], %[[OUTPUT_PORT_3:.*]] = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    // Create flags used for termination detection
    // CHECK-NEXT: %[[TERM_FLAG:.*]] = memref.alloc() : memref<1xi32>
    // CHECK-NEXT: %{{.*}} = memref.atomic_rmw assign %[[C0_I32]], %[[TERM_FLAG]][%[[C0]]] : (i32, memref<1xi32>) -> i32
    // CHECK-NEXT: %[[PROG_FLAGS:.*]] = memref.alloc() : memref<64xi32>
    // CHECK-NEXT: %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[PROG_FLAGS]][%[[C0]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT: %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[PROG_FLAGS]][%[[C16]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT: %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[PROG_FLAGS]][%[[C32]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT: %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[PROG_FLAGS]][%[[C48]]] : (i32, memref<64xi32>) -> i32

    cal.create_instance @src "srcA" (%c10_i32, %c1_i32 : i32, i32)
        ports_out (%inputPort : !fifo.input_port<i32>)
    // CHECK-NEXT: %[[TOKEN_0:.*]] = async.execute {
    // CHECK-NEXT:   scf.while (%arg0 = %[[TRUE]]) : (i1) -> () {
    // CHECK-NEXT:     %{{.*}} = memref.load %[[TERM_FLAG]][%[[C0]]] : memref<1xi32>
    // CHECK-NEXT:     %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C1_I32]] : i32
    // CHECK-NEXT:     %{{.*}} = scf.if %{{.*}} -> (i32) {
    // CHECK-NEXT:       %{{.*}} = memref.atomic_rmw addi %[[C0_I32]], %[[TERM_FLAG]][%[[C0]]] : (i32, memref<1xi32>) -> i32
    // CHECK-NEXT:       scf.yield %{{.*}} : i32
    // CHECK-NEXT:     } else {
    // CHECK-NEXT:       scf.yield %[[C0_I32]] : i32
    // CHECK-NEXT:     }
    // CHECK-NEXT:     %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C0_I32]] : i32
    // CHECK-NEXT:     scf.condition(%{{.*}})
    // CHECK-NEXT:   } do {
    // CHECK-NEXT:     %{{.*}} = func.call @src(%[[C10_I32]], %[[C1_I32]], %[[INPUT_PORT]]) {from_create_instance} : (i32, i32, !fifo.input_port<i32>) -> i1
    // CHECK-NEXT:     scf.if %{{.*}} {
    // CHECK-NEXT:       %{{.*}} = memref.load %[[PROG_FLAGS]][%[[C0]]] : memref<64xi32>
    // CHECK-NEXT:       %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C0_I32]] : i32
    // CHECK-NEXT:       scf.if %{{.*}} {
    // CHECK-NEXT:         %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[PROG_FLAGS]][%[[C0]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT:       }
    // CHECK-NEXT:     }
    // CHECK-NEXT:     scf.yield %[[TRUE]] : i1
    // CHECK-NEXT:   }
    // CHECK-NEXT:   async.yield
    // CHECK-NEXT: }

    cal.create_instance @src "srcB" (%c10_i32, %c2_i32 : i32, i32)
        ports_out (%inputPort_0 : !fifo.input_port<i32>)
    // CHECK-NEXT: %[[TOKEN_1:.*]] = async.execute {
    // CHECK-NEXT:   scf.while (%arg0 = %[[TRUE]]) : (i1) -> () {
    // CHECK-NEXT:     %{{.*}} = memref.load %[[TERM_FLAG]][%[[C0]]] : memref<1xi32>
    // CHECK-NEXT:     %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C1_I32]] : i32
    // CHECK-NEXT:     %{{.*}} = scf.if %{{.*}} -> (i32) {
    // CHECK-NEXT:       %{{.*}} = memref.atomic_rmw addi %[[C0_I32]], %[[TERM_FLAG]][%[[C0]]] : (i32, memref<1xi32>) -> i32
    // CHECK-NEXT:       scf.yield %{{.*}} : i32
    // CHECK-NEXT:     } else {
    // CHECK-NEXT:       scf.yield %[[C0_I32]] : i32
    // CHECK-NEXT:     }
    // CHECK-NEXT:     %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C0_I32]] : i32
    // CHECK-NEXT:     scf.condition(%{{.*}})
    // CHECK-NEXT:   } do {
    // CHECK-NEXT:     %{{.*}} = func.call @src(%[[C10_I32]], %[[C2_I32]], %[[INPUT_PORT_0]]) {from_create_instance} : (i32, i32, !fifo.input_port<i32>) -> i1
    // CHECK-NEXT:     scf.if %{{.*}} {
    // CHECK-NEXT:       %{{.*}} = memref.load %[[PROG_FLAGS]][%[[C16]]] : memref<64xi32>
    // CHECK-NEXT:       %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C0_I32]] : i32
    // CHECK-NEXT:       scf.if %{{.*}} {
    // CHECK-NEXT:         %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[PROG_FLAGS]][%[[C16]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT:       }
    // CHECK-NEXT:     }
    // CHECK-NEXT:     scf.yield %[[TRUE]] : i1
    // CHECK-NEXT:   }
    // CHECK-NEXT:   async.yield
    // CHECK-NEXT: }

    cal.create_instance @merge "merge" ()
        ports_in (%outputPort, %outputPort_1 : !fifo.output_port<i32>, !fifo.output_port<i32>)
        ports_out (%inputPort_2 : !fifo.input_port<i32>)
    // CHECK-NEXT: %[[TOKEN_2:.*]] = async.execute {
    // CHECK-NEXT:   scf.while (%arg0 = %[[TRUE]]) : (i1) -> () {
    // CHECK-NEXT:     %{{.*}} = memref.load %[[TERM_FLAG]][%[[C0]]] : memref<1xi32>
    // CHECK-NEXT:     %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C1_I32]] : i32
    // CHECK-NEXT:     %{{.*}} = scf.if %{{.*}} -> (i32) {
    // CHECK-NEXT:       %{{.*}} = memref.atomic_rmw addi %[[C0_I32]], %[[TERM_FLAG]][%[[C0]]] : (i32, memref<1xi32>) -> i32
    // CHECK-NEXT:       scf.yield %{{.*}} : i32
    // CHECK-NEXT:     } else {
    // CHECK-NEXT:       scf.yield %[[C0_I32]] : i32
    // CHECK-NEXT:     }
    // CHECK-NEXT:     %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C0_I32]] : i32
    // CHECK-NEXT:     scf.condition(%{{.*}})
    // CHECK-NEXT:   } do {
    // CHECK-NEXT:     %{{.*}} = func.call @merge(%[[OUTPUT_PORT]], %[[OUTPUT_PORT_1]], %[[INPUT_PORT_2]]) {from_create_instance} : (!fifo.output_port<i32>, !fifo.output_port<i32>, !fifo.input_port<i32>) -> i1
    // CHECK-NEXT:     scf.if %{{.*}} {
    // CHECK-NEXT:       %{{.*}} = memref.load %[[PROG_FLAGS]][%[[C32]]] : memref<64xi32>
    // CHECK-NEXT:       %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C0_I32]] : i32
    // CHECK-NEXT:       scf.if %{{.*}} {
    // CHECK-NEXT:         %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[PROG_FLAGS]][%[[C32]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT:       }
    // CHECK-NEXT:     }
    // CHECK-NEXT:     scf.yield %[[TRUE]] : i1
    // CHECK-NEXT:   }
    // CHECK-NEXT:   async.yield
    // CHECK-NEXT: }

    cal.create_instance @sink "sink" ()
        ports_in (%outputPort_3 : !fifo.output_port<i32>)
    // CHECK-NEXT: %[[TOKEN_3:.*]] = async.execute {
    // CHECK-NEXT:   scf.while (%arg0 = %[[TRUE]]) : (i1) -> () {
    // CHECK-NEXT:     %{{.*}} = memref.load %[[TERM_FLAG]][%[[C0]]] : memref<1xi32>
    // CHECK-NEXT:     %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C1_I32]] : i32
    // CHECK-NEXT:     %{{.*}} = scf.if %{{.*}} -> (i32) {
    // CHECK-NEXT:       %{{.*}} = memref.atomic_rmw addi %[[C0_I32]], %[[TERM_FLAG]][%[[C0]]] : (i32, memref<1xi32>) -> i32
    // CHECK-NEXT:       scf.yield %{{.*}} : i32
    // CHECK-NEXT:     } else {
    // CHECK-NEXT:       scf.yield %[[C0_I32]] : i32
    // CHECK-NEXT:     }
    // CHECK-NEXT:     %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C0_I32]] : i32
    // CHECK-NEXT:     scf.condition(%{{.*}})
    // CHECK-NEXT:   } do {
    // CHECK-NEXT:     %{{.*}} = func.call @sink(%[[OUTPUT_PORT_3]]) {from_create_instance} : (!fifo.output_port<i32>) -> i1
    // CHECK-NEXT:     scf.if %{{.*}} {
    // CHECK-NEXT:       %{{.*}} = memref.load %[[PROG_FLAGS]][%[[C48]]] : memref<64xi32>
    // CHECK-NEXT:       %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C0_I32]] : i32
    // CHECK-NEXT:       scf.if %{{.*}} {
    // CHECK-NEXT:         %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[PROG_FLAGS]][%[[C48]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT:       }
    // CHECK-NEXT:     }
    // CHECK-NEXT:     scf.yield %[[TRUE]] : i1
    // CHECK-NEXT:   }
    // CHECK-NEXT:   async.yield
    // CHECK-NEXT: }

    // Loop until all actors have indicated termination
    // CHECK-NEXT: scf.while (%arg0 = %[[TRUE]]) : (i1) -> () {
    // CHECK-NEXT:   scf.condition(%arg0)
    // CHECK-NEXT: } do {
    // CHECK-NEXT:   %{{.*}} = memref.atomic_rmw assign %[[C0_I32]], %[[PROG_FLAGS]][%[[C0]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT:   %{{.*}} = memref.atomic_rmw assign %[[C0_I32]], %[[PROG_FLAGS]][%[[C16]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT:   %{{.*}} = memref.atomic_rmw assign %[[C0_I32]], %[[PROG_FLAGS]][%[[C32]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT:   %{{.*}} = memref.atomic_rmw assign %[[C0_I32]], %[[PROG_FLAGS]][%[[C48]]] : (i32, memref<64xi32>) -> i32
    // CHECK-NEXT:   %{{.*}} = arith.ori %{{.*}}, %{{.*}} : i32
    // CHECK-NEXT:   %{{.*}} = arith.ori %{{.*}}, %{{.*}} : i32
    // CHECK-NEXT:   %{{.*}} = arith.ori %{{.*}}, %{{.*}} : i32
    // CHECK-NEXT:   %{{.*}} = arith.cmpi eq, %{{.*}}, %[[C1_I32]] : i32
    // CHECK-NEXT:   %{{.*}} = llvm.call @usleep(%[[C50000_I32]]) : (i32) -> i32
    // CHECK-NEXT:   scf.yield %{{.*}} : i1
    // CHECK-NEXT: }
    // CHECK-NEXT: %{{.*}} = memref.atomic_rmw assign %[[C1_I32]], %[[TERM_FLAG]][%[[C0]]] : (i32, memref<1xi32>) -> i32
    
    // Wait for all actors to complete
    // CHECK-NEXT: async.await %[[TOKEN_0]] : !async.token
    // CHECK-NEXT: async.await %[[TOKEN_1]] : !async.token
    // CHECK-NEXT: async.await %[[TOKEN_2]] : !async.token
    // CHECK-NEXT: async.await %[[TOKEN_3]] : !async.token
    // CHECK-NEXT: return
    // CHECK-NEXT: }
  }
}