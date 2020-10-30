#!/bin/bash

# export BIN_DIR
cd /mnt/local/bin
export BIN_DIR=`pwd`

###################################################################
# CONFIGURE REPEATMASKER & REPEATMODELER 

# configure RepeatMasker 
# will need to enter things in at the prompts
cd /mnt/local/src/RepeatMasker
perl ./configure
# requires user input

# symlink RepeatMasker to bin dir
ln -s "$(pwd)/RepeatMasker" $BIN_DIR

# now configure RepeatModeler
cd /mnt/local/src/RepeatModeler/
perl ./configure
# also requires user input

# make a symlink for RepeatModeler in bin
ln -s "$(pwd)/RepeatModeler" $BIN_DIR

