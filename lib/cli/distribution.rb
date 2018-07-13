module Cli
  class Distribution < Thor
    include Formattable

    desc "ls", "List available distributions"
    option :raw, type: :boolean, default: false
    def ls
      puts Api::Distribution.list(format)
    end
  end
end
