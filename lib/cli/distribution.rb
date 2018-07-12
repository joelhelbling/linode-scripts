module Cli
  class Distribution < Thor
    include Api::Utils

    desc "ls", "List available distributions"
    option :raw, type: :boolean, default: false
    def ls
      if options[:raw]
        puts JSON.pretty_generate(list.map(&:to_h))
      else
        table = standard_table
        distributions = list
        distributions.each do |d|
          table << {
            id: d.distributionid,
            label: d.label,
            x64: d.is64bit == 1
          }
        end

        puts table.to_s
      end

    end

    private

    def list
      api.avail.distributions
    end
  end
end
