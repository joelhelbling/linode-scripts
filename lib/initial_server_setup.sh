#!/bin/bash
#<UDF name="username" label="main user login" default="fooser" description="A non-root (but sudoing) user for the server" />
#<UDF name="github_user" label="GitHub user whose keys will be installed" default="" description="Optional GitHub user for authorized_keys" />
#<UDF name="timezone" label="Timezone of the server" default="" description="Optional timezone for the server" />

initial_server_setup() {
  apt-get update
  apt-get install -y curl wget git tree

  USER_HOME=/home/$USERNAME


  # Add the main user
  useradd -m -s /bin/bash $USERNAME
  PASSWORD="passpass_`echo $USERNAME | rev`_ssapssap"
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

  if [ "$GITHUB_USER" != "" ]; then
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
  if [ "$TIMEZONE" != "" ]; then
    echo $TIMEZONE > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
  fi
  apt-get install -y ntp


  # Setup dotfiles (TODO: deliver these as gists)
  su - -c "curl -sSL https://rvm.io/mpapis.asc | gpg --import -"
  su - -c "echo progress-bar >> ~/.curlrc; \\curl -sSL https://get.rvm.io | bash -s stable --ruby"
  su - -c "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.6/install.sh | bash"
  su - -c "git clone https://github.com/$GITHUB_USER/dot_vim.git .vim" $USERNAME
  su - -c "cd .vim; git submodule init; git submodule update" $USERNAME
  su - -c "git clone https://github.com/$GITHUB_USER/dotfiles.git" $USERNAME
  su - -c "cd dotfiles; ./make_dots.sh" $USERNAME
}

initial_server_setup
