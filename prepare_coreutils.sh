#!/bin/bash

echo -e "\033[0;32mCloning coreutils repository and bootstrapping...\033[0m"
git clone git://git.sv.gnu.org/coreutils
cd coreutils
git checkout 02fc0e3
./bootstrap
mkdir obj-llvm
cd obj-llvm
echo -e "\033[0;32mConfiguring coreutils build....\033[0m"
LLVM_COMPILER=clang CC=wllvm ../configure --disable-nls CFLAGS="-g -O1 -Xclang -disable-llvm-passes -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__"
echo -e "\033[0;32mMaking coreutils...\033[0m"
LLVM_COMPILER=clang make
echo -e "\033[0;32mExtracting bitcode...\033[0m"
cd src
find . -executable -type f | xargs -I '{}' extract-bc '{}'
cd ../../..
