require "sprockets-derailleur/version"
require "sprockets-derailleur/manifest"
require 'logging'

module SpeedUp
  def self.logger
    SpeedUp.get_logger
  end

  def self.get_logger
    return @logger if @logger
    @logger = Logging.logger(STDOUT)
    @logger.level = ENV["LOGGER_LEVEL"].to_sym || :warn
  end
end


module SprocketsDerailleur
  def self.number_of_processors
    if RUBY_PLATFORM =~ /linux/
      return `cat /proc/cpuinfo | grep processor | wc -l`.to_i
    elsif RUBY_PLATFORM =~ /darwin/
      return `sysctl -n hw.physicalcpu`.to_i
    elsif RUBY_PLATFORM =~ /win32/
      # this works for windows 2000 or greater
      require 'win32ole'
      wmi = WIN32OLE.connect("winmgmts://")
      wmi.ExecQuery("select * from Win32_ComputerSystem").each do |system| 
        begin
          processors = system.NumberOfLogicalProcessors
        rescue
          processors = 0
        end
        return [system.NumberOfProcessors, processors].max
      end
    end
    raise "can't determine 'number_of_processors' for '#{RUBY_PLATFORM}'"
  end
end
