# AWS_setup

### Example for launching a new instance

Check to see if there are already instances running

`ssec2C -l`

Create a new i3.large instance to start installing programs

`ssec2L -t i3.large`

Connect to the new instance

`ssec2C -i IDNUMBER`

Once inside the instance, copy over the [AWS_setup/install_all.sh](install_all) script (e.g. using nano or vim or git)


