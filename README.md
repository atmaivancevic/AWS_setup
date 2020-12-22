# AWS_setup

## Example for setting up a new instance

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
cd AWS_setup/
chmod +x install_all.sh 
./install_all.sh 
```

## 3. Configure RepeatMasker and RepeatModeler

Run the [config_RM.sh](config_RM.sh) script. You'll need to feed in the answers below at the prompts. 

```
cd AWS_setup/
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

LTR Structural Identification Pipeline [optional], Do you wish to configure RepeatModeler for this type of analysis: `n`

### Congratulations!  RepeatModeler is now ready to use.

## 4. Copy over MELT

Downloading MELT requires signing this software licence agreement: https://melt.igs.umaryland.edu/downloads.php

I signed it on our behalf (if that counts?) and put the latest release (MELTv2.2.2.tar.gz) on the S3 bucket, under directory repeat_essentials/ 

You'll need to copy this from S3 to the instance and then unpack the .tar.gz file, e.g.:

```
# go to src dir
cd /mnt/local/src

# copy MELTv2.2.2.tar.gz from S3 repeat_essentials/ or from the website above

# unpack
tar zxf MELTv2.2.2.tar.gz
rm MELTv2.2.2.tar.gz

# make symlink
cd MELTv2.2.2
ln -s "$(pwd)/MELT.jar" /mnt/local/bin/MELT.jar
```

For more information about MELT, see https://melt.igs.umaryland.edu/manual.php

## 5. Get ready to run some things

Remember to either log out, or `source ~/.profile` first, to update your .profile to include the new `bin` dir with all installed programs. 

Everything that's been installed can be found in the `bin/` and `src/` dirs of `/mnt/local`. You should create analysis directories & results files on `/mnt/local` too, since $HOME doesn't have much space. 

## 6. RepeatMasker/RepeatModeler analysis
 

## 7. MELT analysis

## 8. Terminate the instance when your analysis is done

Log out

```
exit
```

Then terminate the instance

```
ssec2C -i ID_NUMBER -t
```





