# VerifyConnectPorts (late port validation)

This late verification pass ensures that every `cal.connect` endpoint refers to a valid port name on the referenced instance handle after structural elaboration. It enables IO-agnostic array/interface construction early, with precise diagnostics once instance handles resolve.

- Scope: runs at the end of the `cal-structural-elaboration` composite pipeline
- Validates: port names against concrete actor (and network) definitions; ignores network SSA ports
- Diagnostics: reports which side (source/destination), the entity symbol, the instance name (if available), and lists available ports

## Usage

Run via the structural pipeline:

- cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" your_file.mlir

Typical successful run produces no output. Errors stop the pipeline with messages like:

```text
error: invalid port 'out' on actor 'A' for source; available: out0. At instance inst
  cal.connect %h : !cal.instance<@A> "out" -> %h : !cal.instance<@A> "in0"
```

## Declaring port names on entities

You can declare canonical port names on actors and networks using `in_names` and `out_names` attributes. These names are used by the verifier for existence checks and to list "available" ports in diagnostics.

Example (actor):

```mlir
cal.actor @A()
  in_names ["in0", "in1"]
  out_names ["out0"]
  ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
  ports_out(%out0: !fifo.input_port<i32>)
{
}
```

Example (network):

```mlir
cal.network @N(%p0: i32)
  in_names ["in0"]
  out_names ["out0"]
  ports_in(%netIn: !fifo.output_port<i32>)
  ports_out(%netOut: !fifo.input_port<i32>) {
  // ...
}
```

## Writing robust connects

- Prefer canonical, lower-case port names with numeric suffixes (e.g., `in0`, `out0`)
- When using instance arrays, extract scalar handles with `cal.instance_at` and connect those
- When connecting network ports, you may use the network port SSA values directly; these are exempt from this pass

## Tests

- test/Transforms/VerifyConnectPorts/valid-ports.mlir — minimal positive case
- test/Transforms/VerifyConnectPorts/instance-array-valid.mlir — arrays with concrete actors
- test/Transforms/VerifyConnectPorts/invalid-port.mlir — negative test (bad actor port)
- test/Transforms/VerifyConnectPorts/instance-array-invalid.mlir — negative test (bad array destination)
