require 'thor'
require_relative 'linode/linode'

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
    ensure_udf(options['udf'])

    distribution = options[:distribution]

    # 1) get linode IP address
    server_meta li.show(label)
    # ip_address = server_meta['ips'].first

    # 2) get stackscript_id
    # 3) generate root & user passwords
    # 4) generate JSON parameters

    puts li.rebuild(label,
                    distribution:  distribution,
                    root_password: root_password,
                    stackscript:   stackscript_id,
                    parameters:    json_parameters
                   )
  end

  private

  def li
    @li ||= Linode::Linode
  end

  def ensure_udf(udf)
    unless File.exists?(udf)
      raise <<-ERROR
      You need to create a json file at #{udf}
      You can begin by making a copy of config/udf.example.json
      ERROR
    end
  end
end

