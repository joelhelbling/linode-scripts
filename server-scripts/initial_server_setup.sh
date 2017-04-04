#!/bin/bash
#<UDF name="server_hostname" label="Hostname" default="" description="hostname for this server" />
#<UDF name="username" label="main user login" default="fooser" description="a non-root (but sudoing) user for the server" />
#<UDF name="password" label="main user password" default="" description="a temporary password to be reset on first login" />
#<UDF name="github_user" label="GitHub user whose keys will be installed" default="" description="optional GitHub user for authorized_keys" />
#<UDF name="timezone" label="Timezone of the server" default="" description="optional timezone for the server" />
#<UDF name="gist_id" label="Gist token" default="" description="optional GitHub gist (run as a shell script)" />

log() {
  echo "$SERVER_HOSTNAME - `date +'%Y/%m/%d %H:%M:%S.%N'` :: $1" >> ~/StackScript.log
}

initial_server_setup() {
  log "starting stackscript"

  cat <<EOF > ~/rerun-StackScript
#!/bin/bash

# This script should allow for easier troubleshooting after a failed deploy;
# it re-sets all the UDF parameters before re-running ~root/StackScript.

SERVER_HOSTNAME=$SERVER_HOSTNAME
USERNAME=$USERNAME
GITHUB_USER=$GITHUB_USER
TIMEZONE=$TIMEZONE
GIST_ID=$GIST_ID

source ./StackScript
EOF

  chmod 755 ./rerun-StackScript

  # First, a few useful packages
  apt-get update
  for package in curl wget git tree tmux; do
    apt-get install -y $package
    log "$package path: `which $package`"
  done

  USER_HOME=/home/$USERNAME
  log "USER_HOME: $USER_HOME"


  # Set the hostname
  hostname $SERVER_HOSTNAME
  echo $SERVER_HOSTNAME > /etc/hostname
  sed -i "s/127.0.1.1.*/127.0.1.1 $SERVER_HOSTNAME/" /etc/hosts

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
  log "ssh directory: `ls -al $USER_HOME/.ssh`"


  # Configure sshd
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  log "sshd config: `grep 'PermitRootLogin \(no\|yes\)' /etc/ssh/sshd_config`"
  log "sshd config: `grep 'PasswordAuthentication  \(no\|yes\)' /etc/ssh/sshd_config`"
  systemctl reload sshd


  # Uncomplicated Firewall
  ufw allow OpenSSH
  ufw --force enable
  log "ufw `ufw status`"


  # Setup timezone
  log "desired timezone: $TIMEZONE"
  if [ ! -z "$TIMEZONE" ]; then
    timedatectl set-timezone $TIMEZONE
    log "/etc/timezone: `cat /etc/timezone`"
  fi
  apt-get install -y ntp


  # Run gist
  log "gist to run: $GIST_ID"
  if [ ! -z "$GIST_ID" ]; then
    GIST_URL="https://gist.githubusercontent.com/$GITHUB_USER/$GIST_ID/raw"
    log "gist url: $GIST_URL"
    curl -H "Cache-Control: no-cache" $GIST_URL | bash
  fi
}

initial_server_setup
