
desc 'rebuild a named linode'
task :rebuild => [:ensure_linode_name] do
  puts "ok, rebuilding #{@linode_name}"
end

task :ensure_linode_name do
  raise "Please provide a linode name" unless ENV['LINODE_NAME']

  @linode_name = ENV['LINODE_NAME']
end
