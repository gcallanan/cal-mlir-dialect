// Here we check that the cal.action operation produces expected errors
// RUN: cal-opt -split-input-file %s -verify-diagnostics

// -----

// expected-error @+1 {{custom op 'cal.actor' The cal.execution_body operation in the cal.actor is required to be the last operation in the region.}}
cal.actor @my_actor(){
    cal.execution_body
    {
        %c1 = arith.constant 10 : i32
    }
    %c2 = arith.constant 10 : i32
}

// -----

cal.actor @my_actor(){
    cal.execution_body
    {
        // expected-error @+1 {{'cal.execution_body' op expects parent op 'cal.actor'}}
        cal.execution_body
        {
            %c1 = arith.constant 10 : i32
            %true = arith.constant 1 : i1
            cal.action_done %true : i1
        }
    }
}

// -----

cal.actor @my_actor(){
    cal.execution_body
    {
        %c1 = arith.constant 10 : i32
        %true = arith.constant 1 : i1
        // expected-error @+1 {{'cal.action_done' op must be the last operation in the parent block}}
        cal.action_done %true : i1
        cal.action_done %true : i1
    }
}

// -----

cal.actor @my_actor(){
    cal.execution_body
    {
        // expected-error @+1 {{block with no terminator, has %0 = "arith.constant"() <{value = 10 : i32}> : () -> i32}}
        %c1 = arith.constant 10 : i32
    }
}

// -----

// expected-error @+1 {{'cal.execution_body' op expects parent op 'cal.actor'}}
cal.execution_body
{
}

// -----

// expected-error @+1 {{custom op 'cal.actor' The cal.execution_body operation in the cal.actor is required to be unique and the last operation in the region. You may not have more than one cal.execution_body in this region}}
cal.actor @my_actor(){
    cal.execution_body
    {
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }

    cal.execution_body
    {
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}