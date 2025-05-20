// Here we check that the cal.actor operation produces expected errors
// RUN: cal-opt -split-input-file %s -verify-diagnostics

// expected-error @+1 {{expected '{' to begin a region}}
cal.actor @my_actor1()

// -----

cal.actor @my_actor2()
// expected-error @+1 {{custom op 'cal.actor' expected InputPortType (fifo.input_port<...>) for ports_out argument}}
    ports_out (%arg1: !fifo.output_port<i36>) 
{
}

// -----

cal.actor @my_actor3()
// expected-error @+1 {{custom op 'cal.actor' expected OutputPortType (fifo.output_port<...>) for ports_in argument}}
    ports_in (%arg1: !fifo.input_port<i36>) 
{
}