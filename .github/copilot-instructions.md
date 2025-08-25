# GitHub Copilot Instructions for MLIR CAL Dialect

## Project Overview

This project implements a custom MLIR dialect based on the **CAL (CAL Actor Language)** for dataflow programming. The dialect enables specification of applications as **networks of actors** that communicate through **FIFO channels**, following the **dataflow model of computation**.

## Key Concepts

### Actors
- **Actors** are computational units with:
  - **State variables** (`cal.create_state_var`, `cal.get`, `cal.set`)
  - **Actions** (`cal.action`) that define behavior
  - **Ports** for input (`!fifo.output_port<T>`) and output (`!fifo.input_port<T>`)
  - **Predicates** (`cal.predicate`) that guard action execution

### Networks
- **Networks** (`cal.network`) connect actors through FIFO channels
- **FIFO channels** (`fifo.create<T>(size)`) enable asynchronous communication
- **Actor instances** (`cal.create_instance`) are instantiated in networks

### FIFO Operations
- `fifo.push(port, value)` - Send data to a channel
- `fifo.pop(port)` - Receive data from a channel  
- `fifo.print()` - Debug output functionality

## Code Patterns

### Actor Definition
```mlir
cal.actor @actor_name(%param: type)
    ports_in(%in_port: !fifo.output_port<type>)
    ports_out(%out_port: !fifo.input_port<type>)
{
    // State initialization
    %state = cal.create_state_var<type> : !cal.state_ref<type>
    
    // Action definition
    cal.action "action_name" {
        // Optional predicate
        cal.predicate {
            %condition = // ... compute condition
            cal.predicate_result %condition : i1
        }
        
        // Action body with FIFO operations
        %token = fifo.pop(%in_port : !fifo.output_port<type>) : type
        fifo.push(%out_port : !fifo.input_port<type>, %token : type)
    }
}
```

### Network Definition
```mlir
cal.network {
    // Create FIFO channels
    %in_port, %out_port = fifo.create<type>(buffer_size) : !fifo.input_port<type>, !fifo.output_port<type>
    
    // Instantiate actors
    cal.create_instance @actor_name "instance_name" (%params : type)
        ports_in(%out_port : !fifo.output_port<type>)
        ports_out(%in_port : !fifo.input_port<type>)
}
```

The operations above are defined in [CalOps.td](../include/Dialect/Cal/CalOps.td) and The operations above are defined in [FifoOps.td](../include/Dialect/Fifo/FifoOps.td).

## File Structure

- **`include/Dialect/Cal/`** - Header files for Cal dialect
- **`lib/Dialect/Cal/`** - Implementation files  
- **`include/Conversions/`** - Header files for conversion passes from Fifo/Cal dialects to standard MLIR
- **`lib/Conversions/`** - Implementation files  
- **`include/Transformation/`** - Header files for transformation passes required in this repo, these transformations are applied to standard MLIR
- **`lib/Transformation/`** - Implementation files  
- **`include/Dialect/Fifo/`** - Header files for FIFO dialect
- **`lib/Dialect/Fifo/`** - FIFO dialect implementation
- **`test/Dialect/Cal/`** - Test files for transformations
- **`examples/`** - Example CAL programs

## Common Types

- `i32`, `f64` - Standard MLIR types
- `tensor<NxMxtype>` - Multi-dimensional tensors
- `!fifo.input_port<type>` - FIFO input port type
- `!fifo.output_port<type>` - FIFO output port type  
- `!cal.state_ref<type>` - Actor state reference type

## Coding Guidelines

1. **Use meaningful actor and instance names** that reflect their purpose
2. **Include debug prints** (`fifo.print`) for development and testing
3. **Initialize state variables** properly in actor constructors
4. **Follow dataflow principles** - actors should be independent and communicate only through FIFOs
5. **Use appropriate buffer sizes** for FIFO channels based on data rates

## Examples

For an example of the MLIR dialect see: [examples/merge/merge.mlir](../examples/merge/merge.mlir) and [examples/tensors/tensors.mlir](../examples/tensors/tensors.mlir) for complete working examples demonstrating:
- Multi-actor networks with source/sink patterns
- State management and parameter passing  
- Tensor operations with linalg dialect integration
- Proper FIFO channel setup and actor instantiation

For an example of a conversion pass see: [CalToFunc.cpp](../lib/Conversion/CalToFunc/CalToFunc.cpp)