module PlatformDetector
  WINDOWS = /mingw|win32|cygwin/
  LINUX = /linux/

  def self.getPlatform
    platform = RUBY_PLATFORM
    case platform
    when WINDOWS
      return :windows
    when LINUX
      return :linux
    else
      puts "Platform #{platform} not supported"
    end
  end
end