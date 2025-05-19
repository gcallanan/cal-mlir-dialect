// Here we check that the cal state variable related operations produce expected errors
// RUN: cal-opt -split-input-file %s -verify-diagnostics


// expected-error @+1 {{'cal.create_state_var' op expected stateVarRef to be of type StateVarRefType (!cal.state_ref<'i32'>), but got 'i32'}}
%ref0 = cal.create_state_var<i32> : i32

// -----

// expected-error @+1 {{'cal.create_state_var' op expected stateVarRef state type to be 'i32', but got 'i64'}}
%ref1 = cal.create_state_var<i32> : !cal.state_ref<i64>

// -----

%c0 = arith.constant 0 : i32
// expected-error @+1 {{'cal.get' op expected stateVarRef to be of type StateVarRefType (!cal.state_ref<'i32'>), but got 'i32'}}
%val0 = cal.get(%c0: i32) : i32

// -----


%ref3 = cal.create_state_var<i32> : !cal.state_ref<i32>
// expected-error @+1 {{'cal.get' op expected stateVarRef state type to be 'ui17', but got 'i32'}}
%val1 = cal.get(%ref3: !cal.state_ref<i32>) : ui17

// -----

%c0 = arith.constant 0 : i32
%c1 = arith.constant 1 : i32
// expected-error @+1 {{'cal.set' op expected stateVarRef to be of type StateVarRefType (!cal.state_ref<'i32'>), but got 'i32'}}
cal.set(%c0: i32, %c1: i32)

// -----


%ref3 = cal.create_state_var<i32> : !cal.state_ref<i32>
%c1 = arith.constant 1 : i17
// expected-error @+1 {{'cal.set' op expected stateVarRef state type to be 'i17', but got 'i32'}}
cal.set(%ref3: !cal.state_ref<i32>, %c1: i17)

// -----


cal.actor @act1 (){
    %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.execution_body{
        // expected-error @+1 {{'cal.create_state_var' op cannot create state variable in within cal.execution_body}}
        %ref1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    }
}

// -----