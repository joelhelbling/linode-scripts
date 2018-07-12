require 'thor'

class Server < Thor
  desc "create LABEL", "create a linode server with the provided LABEL"
  option :distribution, default: "Ubuntu 16.04 LTS"
  option :stackscript, default: "linode_initial_setup"
  option :udf, default: './config/udf.json'
  def create(label)

  end

  desc "rebuild LABEL", "rebuild an existing linode server"
  option :distribution, default: "Ubuntu 16.04 LTS"
  option :stackscript, default: "linode_initial_setup"
  option :udf, default: './config/udf.json'
  def rebuild(label)

  end
end

