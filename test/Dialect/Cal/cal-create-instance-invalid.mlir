// RUN: cal-opt -split-input-file %s -verify-diagnostics

cal.actor @simple4()
    ports_out(%out0: !fifo.input_port<i32>)
{
    
}

cal.network @Top_simple4(){
    %c1 = arith.constant 10 : i32
    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    // expected-error @+1 {{custom op 'cal.create_instance' expected fifo.input_port<...> for ports_out}}
    cal.create_instance @simple4 () ports_out(%out0: !fifo.output_port<i32>)
}

// -----

cal.actor @simple3()
    ports_in(%in0: !fifo.output_port<i32>)
{
    
}

cal.network @Top_simple3(){
    %c1 = arith.constant 10 : i32
    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    // expected-error @+1 {{custom op 'cal.create_instance' expected fifo.output_port<...> for ports_in}}
    cal.create_instance @simple3 () ports_in(%in0: !fifo.input_port<i32>)
}

// -----

cal.actor @simple2(%c1: i32)
{
    
}

cal.network @Top_simple2(){
    %c1 = arith.constant 10 : i32
    // expected-error @+1 {{'cal.create_instance' op operand count mismatch: expected 1 operands (actor params+ports), but got 3}}
    cal.create_instance @simple2 (%c1, %c1, %c1: i32, i32, i32)
}

// -----

cal.actor @simple1(%c1: i16)
{
    
}

cal.network @Top_simple1(){
    %c1 = arith.constant 10 : i32
    // expected-error @+1 {{'cal.create_instance' op operand type mismatch for operand 0: expected 'i16', but got 'i32'}}
    cal.create_instance @simple1 (%c1: i32)
}

// -----

cal.network @Top_simple0() {
    // expected-error @+1 {{'cal.create_instance' op 'simple0' does not reference a valid cal.actor or cal.network}}
    cal.create_instance @simple0 ()
}

// -----

// expected-error @+1 {{'cal.create_instance' op expects parent op 'cal.network'}}
cal.create_instance @simple "actor1" ()

// -----