# AWS_setup

### Example for setting up a new instance

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

Next, run the [config_RM.sh](config_RM.sh) script. Note that you'll need to feed in program dirs at the prompts. 

```
cd AWS_setup/
chmod +x config_RM.sh 
./config_RM.sh 
```

**Feed in the following at each of the prompts:**

The full path including the name for the TRF program. TRF_PGRM:`/mnt/local/src/TandemRepeatFinder-409.linux64/trf`

Add a Search Engine: `2`

The path to the installation of the RMBLAST sequence alignment program. RMBLAST_DIR: `/mnt/local/src/rmblast-2.10.0/bin`

Do you want RMBlast to be your default search engine for Repeatmasker (Y/N)? `Y`

Add a Search Engine: `5`

**You should then see confirmation that RepeatMasker has been configured! Yay!**

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

** This should configure RepeatModeler!**








