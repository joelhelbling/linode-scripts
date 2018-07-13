require 'pry'
require 'thor'

require_relative 'formattable'

require_relative 'server'
require_relative 'stackscript'
require_relative 'distribution'

module Cli
  class Lin < Thor
    desc "server", "Do stuff with Linode servers"
    subcommand "server", Server

    desc "stackscript", "Do stuff with Linode stackscripts"
    subcommand "stackscript", Stackscript

    desc "distribution", "Available Linux distributions"
    subcommand "distribution", Distribution
  end
end

