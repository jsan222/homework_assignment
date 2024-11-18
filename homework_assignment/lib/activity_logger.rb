require 'etc'
require 'csv'
require 'time'
require 'sys/proctable'

class ActivityLogger
  include Sys

  UNSUPPORTED_PLATFORM_ERROR = 'Cannot log due to unsupported platform'
  
  def initialize(platform, pid, **attributes)
    @platform = platform
    @process_id = pid

    # sys/proctable gem provides an interface to access process information
    # and supports both Windows and Linux
    process_info = ProcTable.ps(pid: @process_id)
    @timestamp = get_timestamp(process_info)
    @process_name = process_info.name
    @command_line = process_info.cmdline
    
    # optional attributes
    @file_path = attributes[:file_path]
    @activity_descriptor = attributes[:activity_descriptor].to_s
    @source_address_port = attributes[:source_address_port]
    @data_amount = attributes[:data_amount]
    @protocol = attributes[:protocol]
  end

  def log
    variables = self.instance_variables.filter { |var| var != :@platform }
    row = variables.map do |attr| 
      instance_variable_get(attr)
    end

    CSV.open("./log.csv", "a") do |csv|
      csv << row
    end
  rescue => e
    puts "Unable to log: #{e.message}"
  end

  private

  def get_timestamp(process_info)
    case @platform
    when :windows
      process_info.creation_date.to_time.utc
    when :linux
      # Not using sys/proctable here to avoid converting epochs, which can use a
      # base reference time
      ps_time = `ps -p #{@process_id} -o lstart=`.strip
      utc_time= Time.strptime(ps_time, '%a %b %d %H:%M:%S %Y').utc
      utc_time.strftime '%Y-%m-%d %H:%M:%S %Z'
    else
      puts UNSUPPORTED_PLATFORM_ERROR
    end
  end

  def get_username
    Etc.getlogin
  end
end