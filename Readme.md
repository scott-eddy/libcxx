# LLVM - libcxx for NuttX

This repository is an extenstion of work done by [Alan Carvalho](http://acassis.wordpress.com/) maintained by Eddy Scott.  
The original repository can be found on [bitbucket](https://bitbucket.org/acassis/libcxxa).

The intent of this repository is to maintain patches necessary to installl LLVM libcxx in the mainline NuttX development branch
while keeping synced with the [llvm project](https://github.com/llvm-mirror/libcxx)


## Usage
To install libcxx into NuttX simply execute:
`./intall.sh <path_to_nuttx>/nuttx`

This will copy include files, source files, and testing configurations from this repository into the nuttx source directory.  You 
should be able to then copy a given configuration Make.defs and defconfig to the nuttx root directory with, for example:
```
cd <path_to_nuttx>/nuttx/tools
./configure.sh stm32f4discovery/llvmtest
```

and finally build the llvm test configuration with:
```
cd <path_to_nuttx>/nuttx
make
```
