#!/bin/bash
#<UDF name="username" label="main user login" default="fooser" description="a non-root (but sudoing) user for the server" />
#<UDF name="password" label="main user password" default="" description="a temporary password to be reset on first login" />
#<UDF name="github_user" label="GitHub user whose keys will be installed" default="" description="optional GitHub user for authorized_keys" />
#<UDF name="timezone" label="Timezone of the server" default="" description="optional timezone for the server" />
#<UDF name="gist_id" label="Gist token" default="" description="optional GitHub gist (run as a shell script)" />

initial_server_setup() {
  LOG=~/StackScript.log
  log() {
    echo "`date +'%Y/%m/%d %H:%M:%S.%N'` :: $1" >> $LOG
  fi
  log "starting stackscript"

  apt-get update
  apt-get install -y curl wget git tree tmux

  for cmd in curl wget git tree tmux; do
    log "$cmd path: `which $cmd`"
  done

  USER_HOME=/home/$USERNAME
  log "USER_HOME: $USER_HOME"


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
  log "ssh public key: `cat $USER_HOME/.ssh/id_rsa.pub`"

  log "GitHub user: $GITHUB_USER"
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
  log "ufw status: `ufw status`"

  # Setup timezone
  log "desired timezone: $TIMEZONE"
  if [ ! -z "$TIMEZONE" ]; then
    echo $TIMEZONE > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
    log "/etc/timezone: `cat /etc/timezone`"
  fi
  apt-get install -y ntp


  # Run Gist
  log "gist to run: $GIST_ID"
  if [ ! -z "$GIST_ID" ]; then
    GIST_URL="https://gist.githubusercontent.com/$GITHUB_USER/$GIST_ID/raw"
    log "gist url: $GIST_URL"
    curl $GIST_URL | bash
  fi
}

initial_server_setup
