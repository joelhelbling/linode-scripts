require 'diffy'
require 'term/ansicolor'

module Cli
  class Stackscript < Thor
    include Formattable
    include Term::ANSIColor
    include Api::Utils

    desc "ls", "List stackscripts (from Linode)"
    option :raw, type: :boolean, default: false
    def ls
      puts Api::Stackscript.list(format)
    end

    desc "create LABEL", "create a new stackscript"
    option :distribution, default: "Ubuntu 16.04 LTS"
    option :description, default: "Initial setup (as per http://goo.gl/0GLSrd)"
    option :comment, default: "Initial revision"
    def create(label)
      Api::Stackscript.create(label, options).tap do |response|
        puts "Created StackScript \"#{label}\" (ID #{response.stackscriptid})"
      end
    end

    desc "update LABEL", "Push local stackscript changes up to Linode"
    option :distribution, default: "Ubuntu 16.04 LTS"
    option :description, default: "Initial setup (as per http://goo.gl/0GLSrd)"
    option :comment, default: "Revised and uploaded"
    def update(label)
      Api::Stackscript.update(label, options).tap do |response|
          puts "Updated StackScript \"#{label}\" (ID #{response.stackscriptid})"
      end
    end

    desc "rm LABEL", "Delete a stackscript"
    def rm(label)
      Api::Stackscript.delete(label).tap do |response|
        puts "Deleted StackScript \"#{label}\" (ID #{response.stackscriptid})"
      end
    end

    desc "show LABEL", "Display the upstream source code for a stackscript"
    def show(label)
      puts Api::Stackscript.source_from(label)
    end

    desc "diff LABEL", "Check status and diff of local vs published versions of a stackscript"
    def diff(label)
      remote = Api::Stackscript.source_from(label)
      local = read_local label

      diff = Diffy::Diff.new(remote, local, context: 1).map do |line|
        case line
          when /^\+/ then green{line}
          when /^-/ then red{line}
        end
      end.join

      puts diff.to_s.size == 0 ? "Stackscript #{label} is up to date." : diff
    end
  end
end
