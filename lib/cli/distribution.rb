module Cli
  class Distribution < Thor
    include Api::Utils

    desc "ls", "List available distributions"
    option :raw, type: :boolean, default: false
    def ls
      puts send(format, Api::Distribution.list)
    end

    private

    def format
      as_json? ? :as_json : :as_table
    end

    def as_json?
      options[:raw]
    end

    def as_json(list)
      JSON.pretty_generate(list.map(&:to_h))
    end

    def as_table(list)
      list.each_with_object(standard_table) { |d, t| t << d.to_h }
    end
  end
end
