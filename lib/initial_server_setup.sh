#!/bin/bash
#<UDF name="USERNAME" label="main user login" />
#<UDF name="GITHUB_USER" label="GitHub user whose keys will be installed" />

initial_server_setup() {
  apt-get update
  apt-get install -y curl wget

  if [ "$USERNAME" -eq "" ]; then
    USERNAME=foo
  fi

  USER_HOME=/home/$USERNAME

  # Add the main user
  adduser $USERNAME
  usermod -aG sudo sammy

  mkdir $USER_HOME/.ssh
  ssh-keygen -t rsa -f $USER_HOME/.ssh/id_rsa -q -P ""

  if [ "$GITHUB_USER" -ne "" ]; then
    curl "https://github.com/$GITHUB_USER.keys" > $USER_HOME/.ssh/authorized_keys
    chmod 600 $USER_HOME/.ssh/authorized_keys
  fi

  chmod 700 $USER_HOME/.ssh
  chmod 600 $USER_HOME/.ssh/id_rsa
  chown -R $USERNAME:$USERNAME $USER_HOME/.ssh
}

initial_server_setup
