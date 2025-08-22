// RUN: cal-opt --merge-simple-cal-actors %s | FileCheck %s

// CHECK:  cal.actor @merged_actor_cat_and_broadcast_2_f_0_5_cat_and_boundary_3_integrate_4()
// CHECK:    ports_in (
// CHECK:      %arg0: !fifo.output_port<tensor<1x1000000xf64>>
// CHECK:    )
// CHECK:    ports_out (
// CHECK:      %arg1: !fifo.input_port<tensor<1x1000000xf64>>
// CHECK:    )
// CHECK:  {
// CHECK:    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
// CHECK:    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
// CHECK:    cal.action "merged_action" priority=0
// CHECK:    {
// CHECK:      %2 = fifo.pop(%arg0 : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
// CHECK:      %concat = tensor.concat dim(0) %2 : (tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
// CHECK:      %concat_0 = tensor.concat dim(0) %concat : (tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
//             %padded = tensor.pad %concat_0 low[0, 1] high[0, 1] {
// CHECK:      ^bb0(%arg2: index, %arg3: index):
// CHECK:        %cst_2 = arith.constant 0.000000e+00 : f64
// CHECK:        tensor.yield %cst_2 : f64
// CHECK:      } : tensor<1x1000000xf64> to tensor<1x1000002xf64>
//             %expanded = tensor.expand_shape %padded [[0, 1], [2]] output_shape [1, 1, 1000002] : tensor<1x1000002xf64> into tensor<1x1x1000002xf64>
//             %cst = arith.constant dense<[[[1.100000e-03, 9.988000e-01, 1.000000e-04]]]> : tensor<1x1x3xf64>
// CHECK:      %cst_1 = arith.constant 0.000000e+00 : f64
// CHECK:      %3 = tensor.empty() : tensor<1x1x1000000xf64>
// CHECK:      %4 = linalg.fill ins(%cst_1 : f64) outs(%3 : tensor<1x1x1000000xf64>) -> tensor<1x1x1000000xf64>
// CHECK:      %5 = linalg.conv_1d_ncw_fcw {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>} ins(%expanded, %cst : tensor<1x1x1000002xf64>, tensor<1x1x3xf64>) outs(%4 : tensor<1x1x1000000xf64>) -> tensor<1x1x1000000xf64>
//             %collapsed = tensor.collapse_shape %5 [[0, 1], [2]] : tensor<1x1x1000000xf64> into tensor<1x1000000xf64>
// CHECK:      fifo.push(%arg1 : !fifo.input_port<tensor<1x1000000xf64>>, %collapsed : tensor<1x1000000xf64>)
// CHECK:    }
// CHECK:  }

// CHECK:  cal.network {
// CHECK:    %inputPort, %outputPort = fifo.create<tensor<1x1000000xf64>> (1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
// CHECK:    %inputPort_0, %outputPort_1 = fifo.create<tensor<1x1000000xf64>> (1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
// CHECK:    %inputPort_2, %outputPort_3 = fifo.create<tensor<1x1000000xf64>> (1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
// CHECK:    cal.create_instance @initial_conditions "initial_conditions_0" ()
// CHECK:        ports_out (%inputPort : !fifo.input_port<tensor<1x1000000xf64>>)
// CHECK:    cal.create_instance @merge "merge_1" ()
// CHECK:        ports_in (%outputPort, %outputPort_1 : !fifo.output_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>)
// CHECK:        ports_out (%inputPort_2 : !fifo.input_port<tensor<1x1000000xf64>>)
// CHECK:    cal.create_instance @merged_actor_cat_and_broadcast_2_f_0_5_cat_and_boundary_3_integrate_4 "merged_instance_0" ()
// CHECK:        ports_in (%outputPort_3 : !fifo.output_port<tensor<1x1000000xf64>>)
// CHECK:        ports_out (%inputPort_0 : !fifo.input_port<tensor<1x1000000xf64>>)
// CHECK:  }


module {
  cal.actor @f_0()
    ports_in (
      %arg0: !fifo.output_port<tensor<1x1000000xf64>>
    )
    ports_out (
      %arg1: !fifo.input_port<tensor<1x1000000xf64>>
    )
  {
    %state = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.action
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
      fifo.push(%arg1 : !fifo.input_port<tensor<1x1000000xf64>>, %0 : tensor<1x1000000xf64>)
    }
    
  }
  
  cal.actor @merge()
    ports_in (
      %arg0: !fifo.output_port<tensor<1x1000000xf64>>, 
      %arg1: !fifo.output_port<tensor<1x1000000xf64>>
    )
    ports_out (
      %arg2: !fifo.input_port<tensor<1x1000000xf64>>
    )
  {
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action priority=1
    {
      %1 = fifo.pop(%arg0 : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
      fifo.print_tensor(%1) : tensor<1x1000000xf64>
      fifo.push(%arg2 : !fifo.input_port<tensor<1x1000000xf64>>, %1 : tensor<1x1000000xf64>)
    }
    
    cal.action priority=0
    {
      cal.predicate {
        %c1000_i32_0 = arith.constant 1000 : i32
        %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %6 = arith.cmpi slt, %5, %c1000_i32_0 : i32
        cal.predicate_result %6 : i1
      }
      %1 = fifo.pop(%arg1 : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
      %c1_i32 = arith.constant 1 : i32
      %2 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %3 = arith.addi %c1_i32, %2 : i32
      cal.set(%0 : !cal.state_ref<i32>, %3 : i32)
      %c1000_i32 = arith.constant 1000 : i32
      %4 = arith.cmpi eq, %3, %c1000_i32 : i32
      scf.if %4 {
        fifo.print_tensor(%1) : tensor<1x1000000xf64>
      }
      fifo.push(%arg2 : !fifo.input_port<tensor<1x1000000xf64>>, %1 : tensor<1x1000000xf64>)
    }
    
  }
  
  cal.actor @cat_and_broadcast()
    ports_in (
      %arg0: !fifo.output_port<tensor<1x1000000xf64>>
    )
    ports_out (
      %arg1: !fifo.input_port<tensor<1x1000000xf64>>
    )
  {
    %state = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.action
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
      %concat = tensor.concat dim(0) %0 : (tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      fifo.push(%arg1 : !fifo.input_port<tensor<1x1000000xf64>>, %concat : tensor<1x1000000xf64>)
    }
    
  }
  
  cal.actor @integrate()
    ports_in (
      %arg0: !fifo.output_port<tensor<1x1000002xf64>>
    )
    ports_out (
      %arg1: !fifo.input_port<tensor<1x1000000xf64>>
    )
  {
    cal.action
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<tensor<1x1000002xf64>>) : tensor<1x1000002xf64>
      %expanded = tensor.expand_shape %0 [[0, 1], [2]] output_shape [1, 1, 1000002] : tensor<1x1000002xf64> into tensor<1x1x1000002xf64>
      %cst = arith.constant dense<[[[1.100000e-03, 9.988000e-01, 1.000000e-04]]]> : tensor<1x1x3xf64>
      %cst_0 = arith.constant 0.000000e+00 : f64
      %1 = tensor.empty() : tensor<1x1x1000000xf64>
      %2 = linalg.fill ins(%cst_0 : f64) outs(%1 : tensor<1x1x1000000xf64>) -> tensor<1x1x1000000xf64>
      %3 = linalg.conv_1d_ncw_fcw {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>} ins(%expanded, %cst : tensor<1x1x1000002xf64>, tensor<1x1x3xf64>) outs(%2 : tensor<1x1x1000000xf64>) -> tensor<1x1x1000000xf64>
      %collapsed = tensor.collapse_shape %3 [[0, 1], [2]] : tensor<1x1x1000000xf64> into tensor<1x1000000xf64>
      fifo.push(%arg1 : !fifo.input_port<tensor<1x1000000xf64>>, %collapsed : tensor<1x1000000xf64>)
    }
    
  }
  
  cal.actor @initial_conditions()
    ports_out (
      %arg0: !fifo.input_port<tensor<1x1000000xf64>>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c1_i32 : i32)
    cal.action
    {
      cal.predicate {
        %21 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %c1_i32_3 = arith.constant 1 : i32
        %22 = arith.cmpi eq, %21, %c1_i32_3 : i32
        cal.predicate_result %22 : i1
      }
      %c0_i32 = arith.constant 0 : i32
      cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
      %c1000000 = arith.constant 1000000 : index
      %c1 = arith.constant 1 : index
      %generated = tensor.generate  {
      ^bb0(%arg1: index, %arg2: index):
        %21 = arith.index_cast %arg2 : index to i64
        %22 = arith.index_cast %c1000000 : index to i64
        %23 = arith.uitofp %21 : i64 to f64
        %24 = arith.uitofp %22 : i64 to f64
        %25 = arith.divf %23, %24 : f64
        %cst_3 = arith.constant 0.000000e+00 : f64
        %cst_4 = arith.constant 1.000000e+00 : f64
        %26 = arith.subf %cst_4, %cst_3 : f64
        %27 = arith.mulf %26, %25 : f64
        %28 = arith.addf %cst_3, %27 : f64
        tensor.yield %28 : f64
      } : tensor<1x1000000xf64>
      %cst = arith.constant 1.000000e+02 : f64
      %1 = tensor.empty() : tensor<1x1000000xf64>
      %2 = linalg.fill ins(%cst : f64) outs(%1 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %cst_0 = arith.constant 5.000000e-01 : f64
      %3 = tensor.empty() : tensor<1x1000000xf64>
      %4 = linalg.fill ins(%cst_0 : f64) outs(%3 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %cst_1 = arith.constant -1.000000e+00 : f64
      %5 = tensor.empty() : tensor<1x1000000xf64>
      %6 = linalg.fill ins(%cst_1 : f64) outs(%5 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %7 = tensor.empty() : tensor<1x1000000xf64>
      %8 = linalg.mul ins(%generated, %6 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%7 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %9 = tensor.empty() : tensor<1x1000000xf64>
      %10 = linalg.add ins(%8, %4 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%9 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %cst_2 = arith.constant -5.000000e-01 : f64
      %11 = tensor.empty() : tensor<1x1000000xf64>
      %12 = linalg.fill ins(%cst_2 : f64) outs(%11 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %13 = tensor.empty() : tensor<1x1000000xf64>
      %14 = linalg.add ins(%generated, %12 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%13 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %15 = tensor.empty() : tensor<1x1000000xf64>
      %16 = linalg.mul ins(%14, %10 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%15 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %17 = tensor.empty() : tensor<1x1000000xf64>
      %18 = linalg.mul ins(%16, %2 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%17 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %19 = tensor.empty() : tensor<1x1000000xf64>
      %20 = linalg.exp ins(%18 : tensor<1x1000000xf64>) outs(%19 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %concat = tensor.concat dim(0) %20 : (tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      fifo.push(%arg0 : !fifo.input_port<tensor<1x1000000xf64>>, %concat : tensor<1x1000000xf64>)
    }
    
  }
  
  cal.actor @cat_and_boundary()
    ports_in (
      %arg0: !fifo.output_port<tensor<1x1000000xf64>>
    )
    ports_out (
      %arg1: !fifo.input_port<tensor<1x1000002xf64>>
    )
  {
    cal.action
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
      %concat = tensor.concat dim(0) %0 : (tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
      %padded = tensor.pad %concat low[0, 1] high[0, 1] {
      ^bb0(%arg2: index, %arg3: index):
        %cst = arith.constant 0.000000e+00 : f64
        tensor.yield %cst : f64
      } : tensor<1x1000000xf64> to tensor<1x1000002xf64>
      fifo.push(%arg1 : !fifo.input_port<tensor<1x1000002xf64>>, %padded : tensor<1x1000002xf64>)
    }
    
  }
  
  cal.network {
    %inputPort, %outputPort = fifo.create<tensor<1x1000000xf64>> (1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %inputPort_0, %outputPort_1 = fifo.create<tensor<1x1000000xf64>> (1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %inputPort_2, %outputPort_3 = fifo.create<tensor<1x1000000xf64>> (1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %inputPort_4, %outputPort_5 = fifo.create<tensor<1x1000002xf64>> (1) : !fifo.input_port<tensor<1x1000002xf64>>, !fifo.output_port<tensor<1x1000002xf64>>
    %inputPort_6, %outputPort_7 = fifo.create<tensor<1x1000000xf64>> (1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %inputPort_8, %outputPort_9 = fifo.create<tensor<1x1000000xf64>> (1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    cal.create_instance @initial_conditions "initial_conditions_0" ()
        ports_out (%inputPort : !fifo.input_port<tensor<1x1000000xf64>>)
    cal.create_instance @merge "merge_1" ()
        ports_in (%outputPort, %outputPort_1 : !fifo.output_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out (%inputPort_2 : !fifo.input_port<tensor<1x1000000xf64>>)
    cal.create_instance @cat_and_broadcast "cat_and_broadcast_2" ()
        ports_in (%outputPort_3 : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out (%inputPort_8 : !fifo.input_port<tensor<1x1000000xf64>>)
    cal.create_instance @cat_and_boundary "cat_and_boundary_3" ()
        ports_in (%outputPort_7 : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out (%inputPort_4 : !fifo.input_port<tensor<1x1000002xf64>>)
    cal.create_instance @integrate "integrate_4" ()
        ports_in (%outputPort_5 : !fifo.output_port<tensor<1x1000002xf64>>)
        ports_out (%inputPort_0 : !fifo.input_port<tensor<1x1000000xf64>>)
    cal.create_instance @f_0 "f_0_5" ()
        ports_in (%outputPort_9 : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out (%inputPort_6 : !fifo.input_port<tensor<1x1000000xf64>>)
  }
}
