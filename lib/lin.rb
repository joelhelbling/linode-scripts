require 'thor'

require_relative 'server'
require_relative 'stackscript'

class Lin < Thor
  desc "server", "Do stuff with servers"
  subcommand "server", Server

  desc "stackscript", "Do stuff with Linode Stackscripts"
  subcommand "stackscript", Stackscript
end

