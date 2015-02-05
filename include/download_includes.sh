#!/bin/bash


# Audioread:
wget http://www.ee.columbia.edu/~dpwe/resources/matlab/audioread/audioread.zip
unzip audioread.zip
rm audioread.zip


# DTW package:
mkdir columbia_ee_dtw
cd columbia_ee_dtw
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/simmx.m
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpfast.m
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.c
# MEX extension for Linux:
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexglx
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexa64
# MEX extension for OS X
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexmac
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexmaci
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexmaci64
cd ..

# PESQ wrapper:
wget http://www.mathworks.com/matlabcentral/fileexchange/submissions/33820/v/1/download/zip
unzip zip
rm zip

mkdir rasta
cd rasta
wget http://labrosa.ee.columbia.edu/matlab/rastamat/deltas.m
cd ..



