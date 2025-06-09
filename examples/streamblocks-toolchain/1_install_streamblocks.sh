set -e

echo "Cloning Required Streamblocks Directories"
echo ""

git clone https://github.com/streamblocks/streamblocks-tycho
git clone https://github.com/streamblocks/streamblocks-platforms

echo "Installing the frontend: streamblocks-tycho"
echo ""

cd streamblocks-tycho
mvn install -DskipTests

echo "Installing the backend: streamblocks-platforms"
echo "(we are required to be on the *mlir* branch of streamblocks-platforms)"
echo ""

cd ../streamblocks-platforms
git checkout mlir
mvn install -DskipTests

dir=$(pwd)
echo ""
echo "Streamblocks installed. Binary located in $dir"


