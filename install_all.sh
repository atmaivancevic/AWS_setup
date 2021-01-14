#!/bin/bash

###################################################################
# INSTALL ESSENTIALS, FORMAT SSD, MAKE BIR & SRC DIRs

# update all and install pip
sudo apt-get update
sudo apt install python-pip --assume-yes
sudo pip install --upgrade pip

# install more things
sudo apt-get install -y build-essential git libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool pkg-config libssl-dev ncurses-dev awscli python-pip libbz2-dev liblzma-dev unzip openjdk-8-jre-headless

# format SSD and create a dir on /mnt/local 
sudo mkfs -t ext4 /dev/nvme0n1
sudo mkdir /mnt/local
sudo mount /dev/nvme0n1 /mnt/local
sudo chown ubuntu /mnt/local

# make bin and src dirs on /mnt/local
cd /mnt/local/
mkdir bin
mkdir src

# add bin dir to $PATH
echo 'export PATH="/mnt/local/bin:$PATH"' >> ~/.profile
source ~/.profile 

# export BIN_DIR
cd /mnt/local/bin
export BIN_DIR=`pwd`

###################################################################
# INSTALL PROGRAMS

# install bedtools
sudo apt install bedtools

# install gargs
# stay inside bin dir
cd /mnt/local/bin
wget https://github.com/brentp/gargs/releases/download/v0.3.8/gargs_linux
mv gargs_linux gargs
chmod +x gargs

# get bwa
# from inside src dir
cd /mnt/local/src
git clone https://github.com/lh3/bwa.git
cd bwa; make
ln -s "$(pwd)/bwa" $BIN_DIR

# get samtools
cd /mnt/local/src
wget https://github.com/samtools/samtools/releases/download/1.5/samtools-1.5.tar.bz2
bunzip2 samtools-1.5.tar.bz2
tar -xvf samtools-1.5.tar
rm samtools-1.5.tar
cd samtools-1.5/
./configure  --disable-bz2  --disable-lzma
make
ln -s "$(pwd)/samtools" $BIN_DIR
cd /mnt/local/src

###################################################################
# INSTALL REPEATMASKER/REPEATMODELER DEPENDENCIES

# install homebrew
sudo apt install linuxbrew-wrapper --assume-yes

# install cpanm
brew update </dev/null
echo 'export PATH="/home/ubuntu/.linuxbrew/bin:$PATH"' >> ~/.profile
source ~/.profile
brew update </dev/null
brew doctor </dev/null
brew install cpanm

# use cpanm to install JSON
cpanm install JSON --sudo

# install the other perl modules that repeatmodeler requires
cpanm install File::Which --sudo 
cpanm install URI --sudo
cpanm install LWP::UserAgent --sudo 
cpanm install Text::Soundex --sudo

# upgrade python 3.5 to 3.6 
sudo add-apt-repository ppa:deadsnakes/ppa </dev/null
sudo apt-get update
sudo apt-get install python3.6 --assume-yes
sudo apt install python3-pip --assume-yes

# update so that typing “python3” uses python3.6 by default
# can still use python2.7 by typing “python” or “python2”
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1

# install h5py python library
sudo pip3 install --upgrade pip
sudo pip3 install h5py

# install a SSE (Sequence Search Engine)
# RepeatMasker supports CrossMatch, RMBlast, or WUBlast/ABBlast
# we'll use RMblast (i.e. NCBI blast with a RepeatMasker wrapper)
cd /mnt/local/src/
wget http://www.repeatmasker.org/rmblast-2.10.0+-x64-linux.tar.gz
tar zxvf rmblast-2.10.0+-x64-linux.tar.gz
rm rmblast-2.10.0+-x64-linux.tar.gz

# need module hdbm for blast to work
sudo apt-get install python3.6-gdbm

# RepeatMasker also requires an install of Tandem Repeat Finder
cd /mnt/local/src
mkdir TandemRepeatFinder-409.linux64
cd TandemRepeatFinder-409.linux64
wget https://github.com/Benson-Genomics-Lab/TRF/releases/download/v4.09.1/trf409.linux64
mv trf409.linux64 trf
chmod +x trf
ln -s "$(pwd)/trf" $BIN_DIR

# install RECON
cd /mnt/local/src
wget http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz
tar zxvf RECON-1.08.tar.gz
rm RECON-1.08.tar.gz
cd RECON-1.08/src/
make
make install

# instructions say to modify the third line to specify of recon.pl to include bin dir
cd /mnt/local/src/RECON-1.08/scripts
sed -i 's#$path = "";#$path = "/mnt/local/src/RECON-1.08/bin";#g' recon.pl

# install RepeatScout
cd /mnt/local/src
wget http://www.repeatmasker.org/RepeatScout-1.0.6.tar.gz
tar zxvf RepeatScout-1.0.6.tar.gz
rm RepeatScout-1.0.6.tar.gz
cd RepeatScout-1.0.6/
make
ln -s "$(pwd)/RepeatScout" $BIN_DIR

# install RepeatMasker
cd /mnt/local/src
wget http://www.repeatmasker.org/RepeatMasker-4.1.1.tar.gz
gunzip RepeatMasker-4.1.1.tar.gz 
tar xvf RepeatMasker-4.1.1.tar
rm RepeatMasker-4.1.1.tar

# install RepeatModeler
cd /mnt/local/src
git clone https://github.com/Dfam-consortium/RepeatModeler.git

# install zlib
sudo apt install zlib1g-dev

# install genometools
# from inside src dir
cd /mnt/local/src
wget http://genometools.org/pub/genometools-1.6.1.tar.gz
tar zxvf genometools-1.6.1.tar.gz
rm genometools-1.6.1.tar.gz
cd genometools-1.6.1; make cairo=no
ln -s "$(pwd)/bin/gt" $BIN_DIR

# install BLAST+
# from inside src dir
cd /mnt/local/src
wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.11.0+-src.tar.gz
tar xfvz ncbi-blast-2.11.0+-src.tar.gz
rm ncbi-blast-2.11.0+-src.tar.gz
cd ncbi-blast-2.11.0+-src/c++; ./configure
cd ReleaseMT/build
make all_r
cd ../bin
ln -s "$(pwd)/makeblastdb" $BIN_DIR
ln -s "$(pwd)/blastn" $BIN_DIR
ln -s "$(pwd)/blastx" $BIN_DIR

# install cd-hit
# from inside src dir
cd /mnt/local/src
wget https://github.com/weizhongli/cdhit/releases/download/V4.8.1/cd-hit-v4.8.1-2019-0228.tar.gz
tar xfvz cd-hit-v4.8.1-2019-0228.tar.gz
rm cd-hit-v4.8.1-2019-0228.tar.gz
cd cd-hit-v4.8.1-2019-0228; make
ln -s "$(pwd)/cd-hit" $BIN_DIR
ln -s "$(pwd)/cd-hit-est" $BIN_DIR

# install HMMER
# from inside src dir
cd /mnt/local/src
wget http://eddylab.org/software/hmmer/hmmer.tar.gz
tar xfvz hmmer.tar.gz
rm hmmer.tar.gz
cd hmmer-3.3.2
./configure --prefix /mnt/local
make
make check
make install
ln -s "$(pwd)/src/hmmsearch" $BIN_DIR

# install LTR_retriever
# from inside src dir
cd /mnt/local/src
wget https://github.com/oushujun/LTR_retriever/archive/v2.9.0.tar.gz
tar xfvz v2.9.0.tar.gz
rm v2.9.0.tar.gz
cd LTR_retriever-2.9.0/
ln -s "$(pwd)/LTR_retriever" $BIN_DIR

# install mafft
# from inside src dir
cd /mnt/local/src
wget https://mafft.cbrc.jp/alignment/software/mafft-7.475-with-extensions-src.tgz
tar xfvz mafft-7.475-with-extensions-src.tgz
rm mafft-7.475-with-extensions-src.tgz
cd mafft-7.475-with-extensions/core
sed -i 's|PREFIX = /usr/local|PREFIX = /mnt/local|' Makefile
sed -i 's|BINDIR = $(PREFIX)/bin|BINDIR = /mnt/local/bin|' Makefile
make clean
make
make install

# install ninja v0.95
# from inside src dir
cd /mnt/local/src
wget https://github.com/TravisWheelerLab/NINJA/archive/0.95-cluster_only.tar.gz
tar xfvz 0.95-cluster_only.tar.gz
rm 0.95-cluster_only.tar.gz
cd NINJA-0.95-cluster_only/NINJA; make
ln -s "$(pwd)/Ninja" $BIN_DIR

###################################################################
# INSTALL MELT DEPENDENCIES

# check if java version is already 1.8
java -version

# install bowtie2
sudo apt install bowtie2 --assume-yes
