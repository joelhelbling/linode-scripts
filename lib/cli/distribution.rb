module Cli
  class Distribution < Thor
    include Api::Utils

    desc "ls", "List available distributions"
    option :raw, type: :boolean, default: false
    def ls
      puts Api::Distribution.list(format)
    end

    private

    def format
      as_json? ? :json : :table
    end

    def as_json?
      options[:raw]
    end
  end
end
