// Here we check that the cal state variable related operations produce expected errors
// RUN: cal-opt -split-input-file %s -verify-diagnostics


// expected-error @+1 {{'cal.create_state_var' op result must be !cal.state_ref<...>, but got 'i32'}}
%ref0 = cal.create_state_var<i32> : i32

// -----

// expected-error @+1 {{'cal.create_state_var' op state_ref element type ('i64') does not match declared <'i32'>}}
%ref1 = cal.create_state_var<i32> : !cal.state_ref<i64>

// -----

%c0 = arith.constant 0 : i32
// expected-error @+1 {{'cal.get' op expected stateVarRef to be of type}}
%val0 = cal.get(%c0: i32) : i32

// -----


%ref3 = cal.create_state_var<i32> : !cal.state_ref<i32>
// expected-error @+1 {{'cal.get' op expected stateVarRef state type}}
%val1 = cal.get(%ref3: !cal.state_ref<i32>) : i17

// -----

%c0 = arith.constant 0 : i32
%c1 = arith.constant 1 : i32
// expected-error @+1 {{'cal.set' op expected stateVarRef to be of type}}
cal.set(%c0: i32, %c1: i32)

// -----


%ref3 = cal.create_state_var<i32> : !cal.state_ref<i32>
%c2 = arith.constant 1 : i17
// expected-error @+1 {{'cal.set' op expected stateVarRef state type}}
cal.set(%ref3: !cal.state_ref<i32>, %c2: i17)

// -----


// TODO: Re-enable once verifier restores restriction: create_state_var inside execution_body should error.

// -----

// TODO: Re-enable once verifier restores restriction: duplicate execution_body state var creation negative test.

// -----
// TODO: Re-enable once verifier restores restriction: create_state_var inside action should error.

// -----
// TODO: Re-enable once verifier restores restriction: create_state_var inside predicate should error.

// -----
cal.actor @act1 (){
    %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.action{
        cal.predicate {
            %c1 = arith.constant 1 : i32
            // expected-error @+1 {{'cal.set' op cannot modify state variable within cal.predicate}}
            cal.set(%ref0: !cal.state_ref<i32>, %c1: i32)
            %true = arith.constant 1 : i1
            cal.predicate_result %true : i1
        }
    }
}
