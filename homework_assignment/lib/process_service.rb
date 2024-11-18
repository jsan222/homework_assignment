require './lib/activity_logger.rb'
require 'uri'

class ProcessService
  def initialize(platform)
    @platform = platform
  end

  def start_process(command)
    pid = Process.spawn(command)
    log_activity(:start_process, pid)
  end

  def create_file(file_path)
    pid = Process.spawn('ruby', '-e', "File.write('#{file_path}', 'testing')")
    attributes = {
      file_path: File.expand_path(file_path),
      activity_descriptor: :create,
    }
    
    log_activity(:create_file, pid, **attributes)
    Process.wait(pid)
    puts 'File was not created' if !file_exists?(file_path)
  end

  def modify_file(file_path, input)
    file_exists = file_exists?(file_path)
    puts 'File does not exist' if !file_exists
    return unless file_exists

    previous_mtime = File.mtime(file_path)
    pid = Process.spawn('ruby', '-e', "File.open('#{file_path}', 'a') { |file| file.puts '#{input}' }")
    attributes = {
      file_path: File.expand_path(file_path),
      activity_descriptor: :modify,
    }

    log_activity(:modify_file, pid, **attributes)

    # Check last modification time to determine if there was a change
    Process.wait(pid)
    new_mtime = File.mtime(file_path)

    if new_mtime <= previous_mtime
      puts 'File was not modified'
    end
  end

  def delete_file(file_path)
    file_exists = file_exists?(file_path)
    puts 'File does not exist' if !file_exists
    return unless file_exists
    
    pid = Process.spawn('ruby', '-e', "File.delete('#{file_path}')")
    attributes = {
      file_path: File.expand_path(file_path),
      activity_descriptor: :delete,
    }

    log_activity(:delete_file, pid, **attributes)
    Process.wait(pid)
    puts 'File was not deleted' if file_exists?(file_path)
  end

  def file_exists?(file_path)
    File.exist?(file_path)
  end

  def network_connection
    uri = URI.parse('https://postman-echo.com/post')
    port = uri.port
    protocol = uri.scheme
    data = 'data=test'
    public_address = `curl -s https://api64.ipify.org`
    
    pid = Process.spawn('curl', '-X', 'POST', '-s', '-o', '/dev/null', '-d', data, uri.to_s)
    
    attributes = {
      source_address_port: "#{public_address}:#{port}",
      data_amount: data.bytesize,
      protocol: protocol,
    }

    log_activity(:network_activity, pid, **attributes)
  end

  def log_activity(type, pid, **attributes)
    if pid
      ActivityLogger.new(@platform, pid, **attributes).log 
    else
      puts "The #{type.to_s} activity did not trigger a process"
    end
  end
end
