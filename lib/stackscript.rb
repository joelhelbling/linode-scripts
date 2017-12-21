require 'thor'
require 'json'
require 'diffy'
require 'term/ansicolor'
require 'legitable'
require_relative 'lin_utils'

class Stackscript < Thor
  include Term::ANSIColor
  include LinUtils

  desc "ls", "List stackscripts (from Linode)"
  option :raw, type: :boolean, default: false
  def ls
    if options[:raw]
      puts JSON.pretty_generate(list)
    else
      table = Legitable::Table.new(delimiter: '  ')
      scripts = list.values.sort{|x,y| x['revdt'] <=> y['revdt']}.reverse
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

    command = <<-CMD
    linode stackscript create \\
      --label #{label} \\
      --distribution "#{options[:distribution]}" \\
      --codefile "#{source_file}" \\
      --ispublic false \\
      --description "#{options[:description]}" \\
      --revnote "#{options[:comment]}"
    CMD

    puts run(command)
  end

  desc "diff LABEL", "Check status and diff of local vs published versions of a stackscript"
  def diff(label)
    remote = source(label)
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
    puts source(label)
  end

  desc "update LABEL", "Push local stackscript changes up to Linode"
  option :distribution, default: "Ubuntu 16.04 LTS"
  option :description, default: "Initial setup (as per http://goo.gl/0GLSrd)"
  option :comment, default: "Revised and uploaded"
  def update(label)
    # TODO: ensure "./stackscripts/#{label}" exists!
    source_file = "./stackscripts/#{label}"

    command = <<-CMD
    linode stackscript update \\
      --label #{label} \\
      --distribution "#{options[:distribution]}" \\
      --codefile "#{source_file}" \\
      --ispublic false \\
      --description "#{options[:description]}" \\
      --revnote "#{options[:comment]}"
    CMD

    puts run(command)
  end

  desc "rm LABEL", "Delete a stackscript"
  def rm(label)
    command = <<-CMD
    linode stackscript delete \\
      --label #{label}
    CMD

    puts run(command)
  end

  private

  def source(label)
    run "linode stackscript source #{label}"
  end

  def list
    JSON.parse(run 'linode stackscript list -j')
  end

end

