require_relative '../lin_utils'

module Linode
  module Linode
    class << self
      include LinUtils

      def list
        JSON.parse(run 'linode list -j')
      end

      def show(label)
        JSON.parse(run "linode show #{label} -j")
      end

      def rebuild(label, parameters)
        command = <<-CMD
        linode rebuild \
          --label "#{label}" \\
          --distribution "#{parameters[:distribution]}" \\
          --password "#{parameters[:root_password]}" \\
          --stackscript "#{parameters[:stackscript_id]}" \\
          --stackscriptjson #{parameters[:json_parameters]}
        CMD

        run(command)
      end
    end
  end
end
