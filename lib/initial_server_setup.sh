#!/bin/bash
#<UDF name="username" label="main user login" default="fooser" description="a non-root (but sudoing) user for the server" />
#<UDF name="password" label="main user password" default="" description="a temporary password to be reset on first login" />
#<UDF name="github_user" label="GitHub user whose keys will be installed" default="" description="optional GitHub user for authorized_keys" />
#<UDF name="timezone" label="Timezone of the server" default="" description="optional timezone for the server" />
#<UDF name="gist_script" label="Gist to be run as bash" default="" description="optional GitHub gist to be run as a shell script" />

initial_server_setup() {
  apt-get update
  apt-get install -y curl wget git tree tmux

  USER_HOME=/home/$USERNAME


  # Add the main user
  useradd -m -s /bin/bash $USERNAME
  if [ -z "$PASSWORD" ]; then
    PASSWORD="passpass_`echo $USERNAME | rev`_ssapssap"
  fi
  passwd $USERNAME <<EOF
$PASSWORD
$PASSWORD
EOF
  usermod -aG sudo $USERNAME


  # Setup .ssh
  mkdir $USER_HOME/.ssh
  chmod 700 $USER_HOME/.ssh

  ssh-keygen -t rsa -f $USER_HOME/.ssh/id_rsa -q -P ""
  chmod 600 $USER_HOME/.ssh/id_rsa

  if [ ! -z "$GITHUB_USER" ]; then
    curl "https://github.com/$GITHUB_USER.keys" > $USER_HOME/.ssh/authorized_keys
    chmod 600 $USER_HOME/.ssh/authorized_keys
  fi

  chown -R $USERNAME:$USERNAME $USER_HOME/.ssh


  # disable ssh as root


  # disable password authentication


  systemctl reload sshd


  # Uncomplicated Firewall
  ufw allow OpenSSH
  ufw --force enable


  # Setup timezone
  if [ ! -z "$TIMEZONE" ]; then
    echo $TIMEZONE > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
  fi
  apt-get install -y ntp


  # Run Gist
  if [ ! -z "$GIST_SCRIPT" ]; then
    curl https://gist.githubusercontent.com/$GITHUB_USER/$GIST_SCRIPT/raw | bash
  fi
}

initial_server_setup
