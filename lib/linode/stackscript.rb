require_relative '../lin_utils'

module Linode
  module Stackscript
    class << self
      include LinUtils

      def list
        JSON.parse(run 'linode stackscript list -j')
      end

      def show(label)
        JSON.parse(run "linode stackscript show #{label} -j")
      end

      def source(label)
        run "linode stackscript source #{label}"
      end

      def create(label, source_file, options)
        command = <<-CMD
        linode stackscript create \\
          --label #{label} \\
          --distribution "#{options[:distribution]}" \\
          --codefile "#{source_file}" \\
          --ispublic false \\
          --description "#{options[:description]}" \\
          --revnote "#{options[:comment]}"
        CMD

        run(command)
      end

      def update(label, source_file, options)
        command = <<-CMD
        linode stackscript update \\
          --label #{label} \\
          --distribution "#{options[:distribution]}" \\
          --codefile "#{source_file}" \\
          --ispublic false \\
          --description "#{options[:description]}" \\
          --revnote "#{options[:comment]}"
        CMD

        run(command)
      end

      def delete(label)
        run "linode stackscript delete #{label}"
      end
    end
  end
end
