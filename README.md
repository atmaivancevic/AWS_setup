# AWS_setup

### Example for launching a new instance

Check to see if there are already instances running

```ssec2C -l
```

Create a new i3.large instance to start installing programs

```ssec2L -t i3.large```

Connect to the new instance

`ssec2C -i IDNUMBER`

Once inside the instance, install git

`sudo apt-get install git`

Clone this AWS_setup dir, including [install_all.sh](install_all.sh) and [config_RM.sh](config_RM.sh) scripts

`git clone https://github.com/atmaivancevic/AWS_setup.git`

Run the [install_all.sh](install_all.sh) script




