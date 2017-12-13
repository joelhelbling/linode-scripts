module LinUtils
  def run(command)
    result = `#{command}`
    raise "Command Failed:\n\n#{command}\n\n" unless $?.success?
    result
  end
end
