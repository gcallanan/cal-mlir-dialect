#!/bin/bash

set -e

streamblocks-platforms/streamblocks mlir --set generate-single-declaration-per-actor=off --set bypass-AM-generation=on --source-path simple.cal --target-path myproject simple.PassThrough

echo "MLIR Succesfully Generated"
echo "Generated file located in: myproject/code-gen/main.mlir"