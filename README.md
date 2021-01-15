# AWS_setup

## Example for setting up a new instance & running repeat analyses

## 1. Launch an instance and log in

Check to see if there are already instances running

```
ssec2C -l
```

Create a new i3.large instance to start installing programs

```
ssec2L -t i3.large
```

Connect to the new instance

```
ssec2C -i ID_NUMBER
```

## 2. Install all the programs we'll need

Once inside the instance, install git

```
sudo apt-get install git
```

Clone this AWS_setup dir, including [install_all.sh](install_all.sh) and [config_RM.sh](config_RM.sh) scripts

```
git clone https://github.com/atmaivancevic/AWS_setup.git
```

Run the [install_all.sh](install_all.sh) script

```
cd ~/AWS_setup
chmod +x install_all.sh 
./install_all.sh 
```

## 3. Configure RepeatMasker and RepeatModeler

Run the [config_RM.sh](config_RM.sh) script. You'll need to feed in the answers below at the prompts. 

```
cd ~/AWS_setup
chmod +x config_RM.sh 
./config_RM.sh 
```

**Feed in the following at each of the prompts:**

TRF_PGRM: `/mnt/local/src/TandemRepeatFinder-409.linux64/trf`

Add a Search Engine, Enter Selection: `2`

RMBLAST_DIR: `/mnt/local/src/rmblast-2.10.0/bin`

Do you want RMBlast to be your default search engine for Repeatmasker (Y/N)? `Y`

Add a Search Engine, Enter Selection: `5`

### You should then see confirmation that RepeatMasker has been configured! Yay!

Next, configure RepeatModeler. You will need to enter the following:

PERL_INSTALLATION_PATH: `/usr/bin/perl`

REPEATMASKER_DIR: `/mnt/local/src/RepeatMasker`

RECON_DIR: `/mnt/local/src/RECON-1.08/bin`

RSCOUT_DIR: `/mnt/local/src/RepeatScout-1.0.6`

TRF_PGRM: `/mnt/local/src/TandemRepeatFinder-409.linux64/trf`

Add a Search Engine, Enter Selection: `1`

RMBLAST_DIR: `/mnt/local/src/rmblast-2.10.0/bin`

Add a Search Engine, Enter Selection: `3`

LTR Structural Identification Pipeline [optional], Do you wish to configure RepeatModeler for this type of analysis: `y`

GENOMETOOLS_DIR: `/mnt/local/src/genometools-1.6.1/bin`

LTR_RETRIEVER_DIR: `/mnt/local/src/LTR_retriever-2.9.0`

MAFFT_DIR: `/mnt/local/bin`

NINJA_DIR: `/mnt/local/src/NINJA-0.95-cluster_only/NINJA`

CDHIT_DIR: `/mnt/local/src/cd-hit-v4.8.1-2019-0228`

### RepeatModeler is now ready to use.

## 4. Copy over MELT

Downloading MELT requires signing this software licence agreement: https://melt.igs.umaryland.edu/downloads.php

I signed it on our behalf (if that counts?) and put the latest release (MELTv2.2.2.tar.gz) on the S3 bucket, under directory repeat_essentials/ 

You'll need to copy this from S3 to the instance and then unpack the .tar.gz file, e.g.:

```
# go to src dir
cd /mnt/local/src

# copy MELT from S3 dir repeat_essentials/ 
aws s3 cp s3://LAB/repeat_essentials/MELTv2.2.2.tar.gz .

# unpack
tar zxf MELTv2.2.2.tar.gz
rm MELTv2.2.2.tar.gz

# make symlink
cd MELTv2.2.2
ln -s "$(pwd)/MELT.jar" /mnt/local/bin/MELT.jar
```

For more information about MELT, see https://melt.igs.umaryland.edu/manual.php

## 5. Example analysis

Remember to either log out, or `source ~/.profile` first, to update your .profile to include the new `bin` dir with all installed programs. 

Everything that's been installed can be found in the `bin/` and `src/` dirs of `/mnt/local`. You should create analysis directories & results files on `/mnt/local` too, since $HOME doesn't have much space. 

### 5a. RepeatMasker annotation

Export your AWS keys again, in order to download genomes and repeat library files from S3.
```
export AWS_ACCESS_KEY_ID=DUMMY
export AWS_SECRET_ACCESS_KEY=DUMMY2
```

The following will show you how to run repeatmasker and repeatmodeler on your genome of choice. We'll be using the elephant genome as an example.

You will first need to download the elephant genome (on S3: elephant/Chromosomes.v2.fasta) and the repbase library in fasta format ( /repeat_essentials/repbase/RMRBSeqs.fasta). 

```
# e.g. download elephant genome
# (replace LAB with lab name)
cd /mnt/local
mkdir genome
cd genome/
aws s3 cp s3://LAB/elephant/Chromosomes.v2.fasta .

# download repbase library file
cd /mnt/local
mkdir repbase
cd repbase
aws s3 cp s3://LAB/repeat_essentials/repbase/RMRBSeqs.fasta .
``` 

Run RepeatMasker with the default dfam library. Use screen and "-L" to log screen output. 
```
screen -L -S myscreen
mkdir /mnt/local/repeatmasker_defaultlib_output

RepeatMasker -dir /mnt/local/repeatmasker_defaultlib_output -pa 8 --nolow -noisy -xsmall -species Eukaryota /mnt/local/genome/Chromosomes.v2.fasta
```

**Note: using an i3.2xlarge instance, this step took approx 23 hrs (real time) for the elephant genome, 22 hrs for the cow genome, and 16 hrs for the snake genome.**

On another instance, run RepeatMasker again with the Repbase library. Note that this will take longer because it's a much more comprehensive  library. 
```
screen -L -S anotherscreen
mkdir /mnt/local/repeatmasker_repbaselib_output

RepeatMasker -dir /mnt/local/repeatmasker_repbaselib_output -pa 8 --nolow -noisy -xsmall -lib /mnt/local/repbase/RMRBSeqs.fasta /mnt/local/genome/Chromosomes.v2.fasta
```

**Note: using an i3.8xlarge instance, this step took approx 58 hrs for the elephant genome, 50 hrs for the cow genome, and 20 hrs for the snake genome.**

Once these jobs are finished, transfer the results files to S3, e.g.:
```
aws s3 cp Chromosomes.v2.fasta.out.repbaselibrary s3://LAB/repeat_results/
```

### 5b. RepeatModeler annotation

For this step, you will only need your genome (e.g. on S3: elephant/Chromosomes.v2.fasta)

Build a database from the genome, and then run RepeatModeler, e.g.:
```
screen -L -S dumboscreen

/mnt/local/src/RepeatModeler/BuildDatabase -name Dumbo /mnt/local/genome/Chromosomes.v2.fasta

RepeatModeler -database Dumbo -LTRStruct -pa 8 > run.out
```

Then upload the results (most importantly, the consensus sequences) to S3.
```
aws s3 cp YOURFILE s3://LAB/elephant/repeatmodeler/
```

### 5c. MELT analysis

Use the consensus seqs for each genome (identified with RepeatMasker/RepeatModeler) as input to MELT to find potential polymorphic TEs. 

## 6. Terminate the instance when your analysis is done

Log out

```
exit
```

Then terminate the instance

```
ssec2C -i ID_NUMBER -t
```





