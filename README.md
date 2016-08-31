# Linode Scripts

Here is a collection of scripts I've written and collected to facilitate the smooth and easy
deploying of linode servers.

## Objectives

On each new Linode, on your first login, you should find...

- some basic security measures configured
- a defined sudoer user installed
- a defined github user's `authorized_keys` file is installed
- ssh via root is disabled
- ssh via password is disabled
- Your arbitrary shell script, stored in a gist, has been run

## Scope

These scripts have been tested and are known to work with the Linode hosting service, on VPS's running
Linode's 'Ubuntu 16.04 LTS' image.

## Acknowledgements

I also like Digital Ocean!  We are so lucky to have both Linode and DO.  Many of the configurations and security measures in these scripts
are inspired by two of [Digital Ocean's](https://www.digitalocean.com) excellent tutorials:

- [Initial Server Setup with Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04)
- [Additional Recommended Steps for New Ubuntu 14.04 Servers](https://www.digitalocean.com/community/tutorials/additional-recommended-steps-for-new-ubuntu-14-04-servers)
