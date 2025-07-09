#!/bin/bash
# filepath: /mnt/kingston/gareth/software-repos/mlir-cal/cal-mlir-dialect/examples/thalassa-pde-solver/1_install_thalassa_in_venv.sh

echo "Installing thalassa-pde-solver in a virtual environment..."

# Step 1: Initialize the thalassa-repo submodule
echo "Step 1: Initializing the thalassa-repo submodule..."
git submodule update --init --recursive thalassa-repo

# Step 2: Verify Python version
echo "Step 2: Verifying Python version..."

# Try python3.10 first, then python3
PYTHON_BIN=""
if command -v python3.10 &>/dev/null; then
    PYTHON_BIN="python3.10"
elif command -v python3 &>/dev/null; then
    PYTHON_BIN="python3"
else
    echo "Error: Neither python3.10 nor python3 was found in PATH."
    exit 1
fi

# Check version requirements
PYTHON_VERSION=$($PYTHON_BIN -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

if [ "$PYTHON_MAJOR" -gt 3 ] || { [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 10 ]; }; then
    echo "    Found $PYTHON_BIN version $PYTHON_VERSION"
else
    echo "Error: $PYTHON_BIN version $PYTHON_VERSION found, but Python 3.10 or higher is required."
    exit 1
fi

# Step 3: Create a virtual environment
echo "Step 3: Creating a virtual environment..."

VENV_DIR="venv"
$PYTHON_BIN -m venv "$VENV_DIR"

# Check if creation was successful
if [ ! -d "$VENV_DIR" ]; then
    echo "Error: Failed to create virtual environment in $VENV_DIR"
    exit 1
fi

echo "    Virtual environment created at $VENV_DIR"
echo "    Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Step 4: Install thalassa-pde-solver
echo "Step 4: Installing thalassa-pde-solver..."

if [ -d "thalassa-repo" ]; then
    echo "    Installing thalassa-pde-solver from thalassa-repo..."
    pip install --upgrade pip
    pip install -e thalassa-repo
else
    echo "Error: thalassa-repo directory not found!"
    exit 1
fi

echo "Thalassa installation complete!"
echo "To activate the virtual environment again later, run:"
echo "    source $VENV_DIR/bin/activate"


