require './lib/platform_detector'
require './lib/process_service'

# Activity Generator Test Script
# Runs each method to generate endpoint activity and logs the process data
platform = PlatformDetector.getPlatform
process_service = ProcessService.new(platform)

# PROCESS START: start process with executable file with & without optional parameters
# Windows
process_service.start_process('./executables/windows_hello_world.exe') if platform == :windows
process_service.start_process('./executables/windows_hello_world.exe optional') if platform == :windows

# Linux
process_service.start_process('./executables/linux_hello_world') if platform == :linux
process_service.start_process('./executables/linux_hello_world optional') if platform == :linux


# CREATE A FILE
process_service.create_file('./test.txt')

# MODIFY A FILE
process_service.modify_file('./test.txt', 'modified')

# DELETE A FILE
process_service.delete_file('./test.txt')

# NETWORK CONNECTION AND TRANSMISSION
process_service.network_connection