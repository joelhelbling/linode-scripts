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

The script, when it completes, will print (STDOUT) the passwords for both the root user
and the primary sudoing user.

## Installing

You will need both linode-cli and jq to run these scripts.  If you're using a mac with homebrew:

```shell
brew update
brew install linode-cli jq
```

Instructions for setting up linode-cli are [here](https://www.linode.com/docs/platform/linode-cli).

Next, clone this repo (or fork and clone).  You'll need to set parameters for the script
in `./config/udf.json` (which is `.gitignore`d):

```json
{
  "USERNAME": "<your desired username>",
  "GITHUB_USER": "<your github id>",
  "TIMEZONE": "<your preferred timezone>",
  "GIST_ID": "<gist to be run as a script>"
}
```

There is a `./config/udf.example.json` you can copy to start.

Note that the `GIST_ID` is optional; if not provided, then the custom gist script step will
be skipped.  If provided, however, it should be just the SHA part of the Gist's URL.  The
gist URL will be constructed using the `GIST_ID` together with `GITHUB_USER`, so this gist
should belong to the `GITHUB_USER`.

### StackScript

Before you can deploy a new linode, you'll need to push the stackscript up to linode.

`bin/stackscript-create`

For any subsequent changes to the stackscript, run

`bin/stackscript-update`

Once the stackscript is uploaded, and your `./config/udf.json` file is populated

## Scope

These scripts have been tested and are known to work with the Linode hosting service, on VPS's running
Linode's 'Ubuntu 16.04 LTS' image.

## Acknowledgements

I also like Digital Ocean!  We are so lucky to have both Linode and DO.  Many of the configurations and security measures in these scripts
are inspired by two of [Digital Ocean's](https://www.digitalocean.com) excellent tutorials:

- [Initial Server Setup with Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04)
- [Additional Recommended Steps for New Ubuntu 14.04 Servers](https://www.digitalocean.com/community/tutorials/additional-recommended-steps-for-new-ubuntu-14-04-servers)
