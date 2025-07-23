cal.actor @f_0()
    ports_in(%in : !fifo.output_port<tensor<1x1000000xf64>>)
    ports_out(%out : !fifo.input_port<tensor<1x1000000xf64>>)
{
    cal.action {
        %prev = fifo.pop(%in : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
        fifo.push(%out : !fifo.input_port<tensor<1x1000000xf64>>, %prev : tensor<1x1000000xf64>)
    }
}
cal.actor @merge()
    ports_in(%ic: !fifo.output_port<tensor<1x1000000xf64>>, %next: !fifo.output_port<tensor<1x1000000xf64>>)
    ports_out(%out: !fifo.input_port<tensor<1x1000000xf64>>)
{
    %zzero = arith.constant 0 : i32
    %s = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%s: !cal.state_ref<i32>, %zzero: i32)
    cal.action priority=1 {
        %token = fifo.pop(%ic: !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
        fifo.print_tensor(%token) : tensor<1x1000000xf64>
        fifo.push(%out: !fifo.input_port<tensor<1x1000000xf64>>, %token: tensor<1x1000000xf64>)
    }
    cal.action priority=0 {
        cal.predicate {
            %limit = arith.constant 400 : i32
            %s_loc = cal.get(%s: !cal.state_ref<i32>) : i32
            %fire = arith.cmpi slt, %s_loc, %limit : i32
            cal.predicate_result %fire : i1
        }
        %token = fifo.pop(%next: !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
        %s_one = arith.constant 1 : i32
        %s_loc_1 = cal.get(%s: !cal.state_ref<i32>) : i32
        %s_loc_p1 = arith.addi %s_one, %s_loc_1 : i32
        cal.set(%s : !cal.state_ref<i32>, %s_loc_p1 : i32)
        %limit = arith.constant 400 : i32
        %8 = arith.cmpi eq, %s_loc_p1, %limit : i32
        scf.if %8 {
            fifo.print_tensor(%token) : tensor<1x1000000xf64>
        }
        fifo.push(%out: !fifo.input_port<tensor<1x1000000xf64>>, %token: tensor<1x1000000xf64>)
    }
}
cal.actor @cat_and_broadcast()
    ports_in(%in0 : !fifo.output_port<tensor<1x1000000xf64>>)
    ports_out(%out0 : !fifo.input_port<tensor<1x1000000xf64>>)
{
    cal.action {
        %15 = fifo.pop(%in0 : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
        %16 = tensor.concat dim(0) %15 : (tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        fifo.push(%out0 : !fifo.input_port<tensor<1x1000000xf64>>, %16 : tensor<1x1000000xf64>)
    }
}
cal.actor @integrate()
    ports_in(%in : !fifo.output_port<tensor<1x1000002xf64>>)
    ports_out(%out : !fifo.input_port<tensor<1x1000000xf64>>)
{
    cal.action {
        %17 = fifo.pop(%in : !fifo.output_port<tensor<1x1000002xf64>>) : tensor<1x1000002xf64>
        %18 = tensor.expand_shape %17 [[0, 1], [2]] output_shape [1, 1, 1000002] : tensor<1x1000002xf64> into tensor<1x1x1000002xf64>
        %19 = arith.constant dense<[[[0.0011, 0.9988, 0.0001]]]> : tensor<1x1x3xf64>
        %22 = arith.constant 0.0 : f64
        %20 = tensor.empty() : tensor<1x1x1000000xf64>
        %21 = linalg.fill ins(%22 : f64) outs(%20 : tensor<1x1x1000000xf64>) -> tensor<1x1x1000000xf64>
        %23 = linalg.conv_1d_ncw_fcw { strides = dense<[1]> : tensor<1xi64>, dilations = dense<[1]> : tensor<1xi64> }
        	ins(%18, %19 : tensor<1x1x1000002xf64>, tensor<1x1x3xf64>) outs(%21 : tensor<1x1x1000000xf64>)
        	-> tensor<1x1x1000000xf64>
        %24 = tensor.collapse_shape %23 [[0, 1], [2]] : tensor<1x1x1000000xf64> into tensor<1x1000000xf64>
        fifo.push(%out : !fifo.input_port<tensor<1x1000000xf64>>, %24 : tensor<1x1000000xf64>)
    }
}
cal.actor @initial_conditions()
    ports_out(%out : !fifo.input_port<tensor<1x1000000xf64>>)
{
    %one = arith.constant 1 : i32
    %s_first = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%s_first: !cal.state_ref<i32>, %one: i32)
    cal.action {
        cal.predicate {
            %first = cal.get(%s_first: !cal.state_ref<i32>) : i32
            %one_0 = arith.constant 1 : i32
            %fire = arith.cmpi eq, %first, %one_0 : i32
            cal.predicate_result %fire : i1
        }
        %zero = arith.constant 0 : i32
        cal.set(%s_first : !cal.state_ref<i32>, %zero : i32)
        %xN = arith.constant 1000000 : index
        %dummyN = arith.constant 1 : index
        %x = tensor.generate {
            ^bb0(%dummyi: index, %xi: index):
            %x_i64 = arith.index_cast %xi : index to i64
            %xN_i64 = arith.index_cast %xN : index to i64
            %xif = arith.uitofp %x_i64 : i64 to f64
            %xNf = arith.uitofp %xN_i64 : i64 to f64
            %dx = arith.divf %xif, %xNf : f64
            %start = arith.constant 0.000000000 : f64
            %end = arith.constant 1.000000000 : f64
            %d = arith.subf %end, %start : f64
            %sz = arith.mulf %d, %dx : f64
            %res = arith.addf %start, %sz : f64
            tensor.yield %res : f64
        } : tensor<1x1000000xf64>
        %25 = arith.constant 100.000000000 : f64
        %26 = tensor.empty() : tensor<1x1000000xf64>
        %27 = linalg.fill ins(%25 : f64) outs(%26 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %28 = arith.constant 0.500000000 : f64
        %29 = tensor.empty() : tensor<1x1000000xf64>
        %30 = linalg.fill ins(%28 : f64) outs(%29 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %31 = arith.constant -1.000000000 : f64
        %32 = tensor.empty() : tensor<1x1000000xf64>
        %33 = linalg.fill ins(%31 : f64) outs(%32 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %34 = tensor.empty() : tensor<1x1000000xf64>
        %35 = linalg.mul ins(%x, %33 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%34 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %36 = tensor.empty() : tensor<1x1000000xf64>
        %37 = linalg.add ins(%35, %30 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%36 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %38 = arith.constant -0.500000000 : f64
        %39 = tensor.empty() : tensor<1x1000000xf64>
        %40 = linalg.fill ins(%38 : f64) outs(%39 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %41 = tensor.empty() : tensor<1x1000000xf64>
        %42 = linalg.add ins(%x, %40 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%41 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %43 = tensor.empty() : tensor<1x1000000xf64>
        %44 = linalg.mul ins(%42, %37 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%43 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %45 = tensor.empty() : tensor<1x1000000xf64>
        %46 = linalg.mul ins(%44, %27 : tensor<1x1000000xf64>, tensor<1x1000000xf64>) outs(%45 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %47 = tensor.empty() : tensor<1x1000000xf64>
        %48 = linalg.exp ins(%46 : tensor<1x1000000xf64>) outs(%47 : tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %49 = tensor.concat dim(0) %48 : (tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        fifo.push(%out : !fifo.input_port<tensor<1x1000000xf64>>, %49 : tensor<1x1000000xf64>)
    }
}
cal.actor @cat_and_boundary()
    ports_in(%f_0 : !fifo.output_port<tensor<1x1000000xf64>>)
    ports_out(%out : !fifo.input_port<tensor<1x1000002xf64>>)
{
    cal.action {
        %50 = fifo.pop(%f_0 : !fifo.output_port<tensor<1x1000000xf64>>) : tensor<1x1000000xf64>
        %51 = tensor.concat dim(0) %50 : (tensor<1x1000000xf64>) -> tensor<1x1000000xf64>
        %52 = tensor.pad %51 low[0, 1] high[0, 1] {
        ^bb0(%i0 : index, %i1 : index):
            %53 = arith.constant 0.000000000 : f64
            tensor.yield %53 : f64
        } : tensor<1x1000000xf64> to tensor<1x1000002xf64>
        fifo.push(%out : !fifo.input_port<tensor<1x1000002xf64>>, %52 : tensor<1x1000002xf64>)
    }
}
cal.network {
    %initial_conditions_merge_i, %initial_conditions_merge_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %integrate_merge_i, %integrate_merge_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %merge_cat_and_broadcast_i, %merge_cat_and_broadcast_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %cat_and_boundary_integrate_i, %cat_and_boundary_integrate_o = fifo.create<tensor<1x1000002xf64>>(1) : !fifo.input_port<tensor<1x1000002xf64>>, !fifo.output_port<tensor<1x1000002xf64>>
    %f_0_cat_and_boundary_i, %f_0_cat_and_boundary_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %cat_and_broadcast_f_0_i, %cat_and_broadcast_f_0_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    
    cal.create_instance @initial_conditions "initial_conditions_0" ()
        ports_out(%initial_conditions_merge_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
    cal.create_instance @merge "merge_1" ()
        ports_in(%initial_conditions_merge_o, %integrate_merge_o : !fifo.output_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out(%merge_cat_and_broadcast_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
    cal.create_instance @cat_and_broadcast "cat_and_broadcast_2" ()
        ports_in(%merge_cat_and_broadcast_o : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out(%cat_and_broadcast_f_0_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
    cal.create_instance @cat_and_boundary "cat_and_boundary_3" ()
        ports_in(%f_0_cat_and_boundary_o : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out(%cat_and_boundary_integrate_i : !fifo.input_port<tensor<1x1000002xf64>>)
    
    cal.create_instance @integrate "integrate_4" ()
        ports_in(%cat_and_boundary_integrate_o : !fifo.output_port<tensor<1x1000002xf64>>)
        ports_out(%integrate_merge_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
    cal.create_instance @f_0 "f_0_5" ()
        ports_in(%cat_and_broadcast_f_0_o : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out(%f_0_cat_and_boundary_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
}
