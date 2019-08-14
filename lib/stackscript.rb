require 'thor'
require 'json'
require 'diffy'
require 'term/ansicolor'
require 'legitable'
require_relative 'linode/stackscript'

class Stackscript < Thor
  include Term::ANSIColor

  desc "ls", "List stackscripts (from Linode)"
  option :raw, type: :boolean, default: false
  def ls
    if options[:raw]
      puts JSON.pretty_generate(sc.list)
    else
      table = Legitable::Table.new(delimiter: '  ')
      scripts = sc.list.values.sort{|x,y| x['revdt'] <=> y['revdt']}.reverse
      scripts.each do |script|
        table << {
          id: script['id'],
          label: script['label'],
          updated: script['revdt'],
          deployments: "#{script['deploymentsactive']}/#{script['deploymentstotal']}",
          note: script['revnote']
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
    # TODO: ensure "./stackscripts/#{label}" exists!
    source_file = "./stackscripts/#{label}"

    puts sc.create(label, source_file, options)
  end

  desc "diff LABEL", "Check status and diff of local vs published versions of a stackscript"
  def diff(label)
    remote = sc.source(label)
    local = File.read("./stackscripts/#{label}")

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
    puts sc.source(label)
  end

  desc "update LABEL", "Push local stackscript changes up to Linode"
  option :distribution, default: "Ubuntu 16.04 LTS"
  option :description, default: "Initial setup (as per http://goo.gl/0GLSrd)"
  option :comment, default: "Revised and uploaded"
  def update(label)
    # TODO: ensure "./stackscripts/#{label}" exists!
    source_file = "./stackscripts/#{label}"

    puts sc.update(label, source_file, options)
  end

  desc "rm LABEL", "Delete a stackscript"
  def rm(label)
    puts sc.delete(label)
  end

  private

  def sc
    @sc ||= Linode::Stackscript
  end
end
