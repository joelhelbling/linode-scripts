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
    command = 'linode stackscript list -j'

    json = run(command)

    if options[:raw]
      puts json
    else
      table = Legitable::Table.new(delimiter: '  ')
      scripts = JSON.parse(json).values.sort{|x,y| x['revdt'] <=> y['revdt']}.reverse
      scripts.each do |script|
        table << {
          label: script['label'],
          updated: script['revdt'],
          deployments: "#{script['deploymentsactive']} / #{script['deploymentstotal']}",
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
    remote = run "linode stackscript source #{label}"
    local = File.read("./stackscripts/#{label}")

    diff = Diffy::Diff.new(remote, local, context: 1).map do |line|
      case line
        when /^\+/ then green{line}
        when /^-/ then red{line}
      end
    end.join

    puts diff.to_s.size == 0 ? "Stackscript #{label} is up to date." : diff
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
end

