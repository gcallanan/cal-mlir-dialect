// Here we check that the cal.action operation produces expected errors
// RUN: cal-opt -split-input-file %s -verify-diagnostics

// -----

// expected-error @+1 {{custom op 'cal.actor' Expected all cal.action operations in the cal.actor to appear at the end of the region. In this cal.actor, some non-action operations were found after a cal.action operation.}}
cal.actor @my_actor(){
    cal.action
    {
        %c1 = arith.constant 10 : i32
    }
    %c2 = arith.constant 10 : i32
}

// // -----

cal.actor @my_actor(){
    cal.action
    {
        // expected-error @+1 {{'cal.action' op expects parent op 'cal.actor'}}
        cal.action
        {
            %c1 = arith.constant 10 : i32
            %true = arith.constant 1 : i1
            cal.action_done %true : i1
        }
    }
}

// // -----

cal.actor @my_actor(){
    cal.action
    {
        %c1 = arith.constant 10 : i32
        %true = arith.constant 1 : i1
        // expected-error @+1 {{'cal.action_done' op must be the last operation in the parent block}}
        cal.action_done %true : i1
        cal.action_done %true : i1
    }
}

// // -----

cal.actor @my_actor(){
    cal.action
    {
        // expected-error @+1 {{block with no terminator, has %0 = "arith.constant"() <{value = 10 : i32}> : () -> i32}}
        %c1 = arith.constant 10 : i32
    }
}

// -----

// expected-error @+1 {{'cal.action' op expects parent op 'cal.actor'}}
cal.action
{
}