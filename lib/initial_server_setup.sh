#!/bin/bash
#<UDF name="USERNAME" label="main user login" default="fooser" description="A non-root (but sudoing) user for the server" />
#<UDF name="GITHUB_USER" label="GitHub user whose keys will be installed" default="" description="Optional GitHub user for authorized_keys" />
#<UDF name="TIMEZONE" label="Timezone of the server" default="" description="Optional timezone for the server" />

initial_server_setup() {
  apt-get update
  apt-get install -y curl wget git tree

  USER_HOME=/home/$USERNAME


  # Add the main user
  adduser \
    --create-home \
    --password "passpass_`echo $USERNAME | rev`_ssapssap" \
    --shell /bin/bash \
    --user-group
    $USERNAME
  usermod -aG sudo $USERNAME


  # Setup .ssh
  mkdir $USER_HOME/.ssh
  chmod 700 $USER_HOME/.ssh

  ssh-keygen -t rsa -f $USER_HOME/.ssh/id_rsa -q -P ""
  chmod 600 $USER_HOME/.ssh/id_rsa

  if [ "$GITHUB_USER" -ne "" ]; then
    curl "https://github.com/$GITHUB_USER.keys" > $USER_HOME/.ssh/authorized_keys
    chmod 600 $USER_HOME/.ssh/authorized_keys
  fi

  chown -R $USERNAME:$USERNAME $USER_HOME/.ssh


  # disable ssh as root


  # disable password authentication


  systemctl reload sshd


  # Uncomplicated Firewall
  ufw allow OpenSSH
  ufw enable


  # Setup timezone
  if [ "$TIMEZONE" -ne "" ]; then
    echo $TIMEZONE > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
  fi
  apt-get install ntp


  # Setup dotfiles (TODO: deliver these as gists)
  su - -c "git clone https://github.com/$GITHUB_USER/dot_vim.git .vim" $USERNAME
  su - -c "cd .vim; git submodules init" $USERNAME
  su - -c "git clone https://github.com/$GITHUB_USER/dotfiles.git" $USERNAME
  su - -c "cd dotfiles; ./make_dots.sh" $USERNAME
}

initial_server_setup
