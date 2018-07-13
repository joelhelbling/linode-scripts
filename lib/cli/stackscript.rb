require 'json'
require 'diffy'
require 'term/ansicolor'

module Cli
  class Stackscript < Thor
    include Term::ANSIColor
    include Api::Utils

    desc "ls", "List stackscripts (from Linode)"
    option :raw, type: :boolean, default: false
    def ls
      if options[:raw]
        puts JSON.pretty_generate(list.map(&:to_h))
      else
        table = standard_table
        scripts = list.sort{|x,y| x.rev_dt <=> y.rev_dt}.reverse
        scripts.each do |script|
          table << {
            id: script.stackscriptid,
            label: script.label,
            updated: script.rev_dt,
            deployments: "#{script.deploymentsactive}/#{script.deploymentstotal}",
            note: script.rev_note
          }
        end
        puts table.to_s
      end
    end

    desc "create LABEL", "create a new stackscript"
    option :distribution, default: "Ubuntu 16.04 LTS"
    option :description, default: "Initial setup (as per http://goo.gl/0GLSrd)"
    option :comment, default: "Initial revision"
    def create(label)
      script = read_local label

      api.stackscript.create(
        Label: label,
        Description: options[:description],
        DistributionIDList: Api::Distribution.id_from(options[:distribution]),
        isPublic: false,
        rev_note: options[:comment],
        script: script
      ).tap do |response|

        puts "Created StackScript \"#{label}\" (ID #{response.stackscriptid})"
      end
    end

    desc "diff LABEL", "Check status and diff of local vs published versions of a stackscript"
    def diff(label)
      remote = source_for(label)
      local = read_local label

      diff = Diffy::Diff.new(remote, local, context: 1).map do |line|
        case line
          when /^\+/ then green{line}
          when /^-/ then red{line}
        end
      end.join

      puts diff.to_s.size == 0 ? "Stackscript #{label} is up to date." : diff
    end

    desc "show LABEL", "Display the upstream source code for a stackscript"
    def show(label)
      puts source_for(label)
    end

    desc "update LABEL", "Push local stackscript changes up to Linode"
    option :distribution, default: "Ubuntu 16.04 LTS"
    option :description, default: "Initial setup (as per http://goo.gl/0GLSrd)"
    option :comment, default: "Revised and uploaded"
    def update(label)
      script = read_local label

      api.stackscript.update(
        StackScriptID: id_for(label),
        Label: label,
        Description: options[:description],
        DistributionIDList: Api::Distribution.id_from(options[:distribution]),
        isPublic: false,
        rev_note: options[:comment],
        script: script
      ).tap do |response|

        puts "Updated StackScript \"#{label}\" (ID #{response.stackscriptid})"
      end
    end

    desc "rm LABEL", "Delete a stackscript"
    def rm(label)
      api.stackscript.delete(StackScriptID: id_for(label)).tap do |response|
        puts "Deleted Stackscript \"#{label}\" (ID #{response.stackscriptid})"
      end
    end

    private

    def id_for(label)
      find_by_label(label).stackscriptid
    end

    def source_for(label)
      find_by_label(label).script
    end

    def find_by_label(label)
      list.find { |script| script.label == label }.tap do |script|
        raise "StackScript \"#{label}\" was not found!" if script.nil?
      end
    end

    def list
      @list ||= api.stackscript.list
    end
  end
end
