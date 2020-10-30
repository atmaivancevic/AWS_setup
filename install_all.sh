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

