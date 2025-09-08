# generic command line passing
#
# sets vars as attributes based on passed in config 'options': e.g.
# [
#  { arg: '-mpxn', args: 1, var: :mpxns, parse: 'mpxn_split_list', help: 'comma separated list of mpxns' },
#  { arg: '-data', args: 0, var: :download_data }
# ]
class ParseCommandLine
  def initialize(options)
    options.push({ arg: '-help', args: 0, var: :help })
    options.each { |p| self.class.send(:attr_reader, p[:var]) }
    @command_line_options = options
  end

  def parse
    args = ARGV
    while !args.empty?
      process = @command_line_options.select { |option| option[:arg] == args[0] }[0]
      args.shift
      if process[:args] == 0
        set_instance(process[:var], true)
      else
        var = process.key?(:parse) ? send(process[:parse], args[0]) : args[0]
        set_instance(process[:var], var)
        args.shift
      end
    end
    if help
      help_options
      exit
    end
  end

  private

  def help_options
    puts
    puts 'Command line options:'
    @command_line_options.each do |arg|
      puts sprintf('  %-15.15s', arg[:arg]) + (arg[:args] == 0 ? '' : " <#{arg.fetch(:help, 'arg')}>")
    end
  end

  def set_instance(name, val)
    instance_variable_set("@#{name}", val)
  end
end