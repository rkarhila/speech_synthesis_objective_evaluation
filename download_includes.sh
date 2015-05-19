#!/bin/bash

cd include


date > download_includes.log


echo "Downloading Audioread from http://www.ee.columbia.edu/~dpwe/resources/matlab/audioread/"

# Audioread:
wget http://www.ee.columbia.edu/~dpwe/resources/matlab/audioread/audioread.zip >> download_includes.log
unzip audioread.zip  >> download_includes.log
rm audioread.zip 



echo "Downloading DTW packages from http://www.ee.columbia.edu/ln/labrosa/matlab/dtw"


# DTW package:
mkdir -p columbia_ee_dtw
cd columbia_ee_dtw
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/simmx.m >> ../download_includes.log
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpfast.m >> ../download_includes.log
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.c >> ../download_includes.log
# MEX extension for Linux:
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexglx >> ../download_includes.log
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexa64 >> ../download_includes.log
# MEX extension for OS X
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexmac >> ../download_includes.log
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexmaci >> ../download_includes.log
wget http://www.ee.columbia.edu/ln/labrosa/matlab/dtw/dpcore.mexmaci64 >> ../download_includes.log
cd ..


echo "Downloading PESQ wrapper from  http://www.mathworks.com/matlabcentral/fileexchange/submissions/33820"

# PESQ wrapper:
wget http://www.mathworks.com/matlabcentral/fileexchange/submissions/33820/v/1/download/zip  >> download_includes.log
unzip zip  >> download_includes.log
rm zip  >> download_includes.log


echo "Downloading one file from RASTA http://labrosa.ee.columbia.edu/matlab/rastamat/"

# RASTA - just one file for delta feature calculation
mkdir -p rasta
cd rasta
wget http://labrosa.ee.columbia.edu/matlab/rastamat/deltas.m >> ../download_includes.log
cd ..


echo "Downloading COLEA from  http://ecs.utdallas.edu/loizou/speech/"

# COLEA
wget http://ecs.utdallas.edu/loizou/speech/colea.tar >> download_includes.log
tar xvf colea.tar >> download_includes.log
rm colea.tar


echo "Downloading VOICEBOX from  http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/"

# VOICEBOX
mkdir -p voicebox
cd voicebox
wget http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.zip  >> ../download_includes.log
unzip voicebox.zip >> ../download_includes.log
rm voicebox.zip
cd ..


echo "Downloading and patching GMMBAYES from http://www.it.lut.fi/project/gmmbayes"

# GMMBAYES - Gaussian Mixture Model Methods
wget http://www.it.lut.fi/project/gmmbayes/downloads/src/gmmbayestb/gmmbayestb-v1.0.tar.gz
tar xvzf gmmbayestb-v1.0.tar.gz >> download_includes.log
rm gmmbayestb-v1.0.tar.gz

cd gmmbayestb-v1.0
cp gmmb_em.m gmmb_em_d.m >> ../download_includes.log
patch gmmb_em_d.m < diagonal_covar.patch >> ../download_includes.log

cd ..


echo "Cloning export_fig from https://github.com/ojwoodford/export_fig"

# export_fig
git clone https://github.com/ojwoodford/export_fig


cd ..

