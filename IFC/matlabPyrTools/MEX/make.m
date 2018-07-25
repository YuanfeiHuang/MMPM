% This make.m is used under Windows

% add -largeArrayDims on 64-bit machines

mex -largeArrayDims -O -c histo.c
mex -largeArrayDims -O -c corrDn.c
mex -largeArrayDims -O -c pointOp.c
mex -largeArrayDims -O -c range2.c
mex -largeArrayDims -O -c upConv.c
mex -largeArrayDims -O -c innerProd.c