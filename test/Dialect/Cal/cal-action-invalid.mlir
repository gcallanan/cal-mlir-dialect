// Here we check that the cal.action operation produces expected errors
// RUN: cal-opt -split-input-file %s -verify-diagnostics

// -----

cal.actor @my_actor(){
    cal.action
    {
        cal.predicate {
            // expected-error @+1 {{block with no terminator, has %0 = "arith.constant"() <{value = true}> : () -> i1}}
            %true = arith.constant 1 : i1
        }
    }
}

// -----

cal.actor @my_actor(){
    cal.action
    {
        %true = arith.constant 1 : i1
        // expected-error @+1 {{'cal.predicate_result' op expects parent op 'cal.predicate'}}
        cal.predicate_result %true : i1
    }
}

// // // -----

cal.actor @my_actor(){
    cal.action
    {
        // expected-error @+1 {{'cal.action' op expects parent op 'cal.actor'}}
        cal.action
        {
            %c1 = arith.constant 10 : i32
        }
    }
}

// -----

// expected-error @+1 {{'cal.action' op expects parent op 'cal.actor'}}
cal.action
{
}

// -----

// expected-error @+1 {{custom op 'cal.actor' expected all cal.action operations in the cal.actor to appear at the end of the region. In this cal.actor, some non - action operations were found after a cal.action operation.}}
cal.actor @my_actor(){
    cal.action
    {
        %c1 = arith.constant 10 : i32
    }

    %c1 = arith.constant 10 : i32

    cal.action
    {
        %c2 = arith.constant 10 : i32
    }
}

// -----

// expected-error @+1 {{custom op 'cal.actor' . Within a cal.actor, there can either be a single cal.execution body or one or more cal.actions. Both of the operations may not appear in the same cal.actor.}}
cal.actor @my_actor(){
    cal.action
    {
        %c1 = arith.constant 10 : i32
    }

    cal.execution_body
    {
    }
}

// -----

// expected-error @+1 {{custom op 'cal.actor' . Within a cal.actor, there can either be a single cal.execution body or one or more cal.actions. Both of the operations may not appear in the same cal.actor.}}
cal.actor @my_actor(){
    cal.execution_body
    {
    }

    cal.action
    {
        %c1 = arith.constant 10 : i32
    }

}

// -----

// expected-error @+1 {{custom op 'cal.actor' . Within a cal.actor, there can either be a single cal.execution body or one or more cal.actions. Both of the operations may not appear in the same cal.actor.}}
cal.actor @my_actor(){
    cal.action
    {
        %c1 = arith.constant 10 : i32
    }
    
    cal.execution_body
    {
    }

    cal.action
    {
        %c1 = arith.constant 10 : i32
    }

}