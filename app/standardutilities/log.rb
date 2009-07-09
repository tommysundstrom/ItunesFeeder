#
#  Log.rb 
#
#  Created by Tommy Sundström on 12/3-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

require 'osx/cocoa'
require 'pathstring'
require 'rubygems'
require 'log4r'


# When this source file is loaded, it cleans out old logs.
def clean_out_log_directory(dir)
  Pathstring(dir).children.each do |item|
    if item.directory?
      # First clean out inside the directory
      clean_out_log_directory(item)

      # Then, if it is empty, delete it
      if item.empty?
        # OSX::NSLog "Removing directory: #{file.basename}"
        item.unlink
      end
    else # Not a directory, so a normal file
      unless Pathstring(item).basename.scan(/rolling/)[0] # Note: This depends on the convention to include 'rolling' in the name of persistent files. TODO: Remove older rolling logs.
         # If it is not a persistent log
         #   remove it
         # OSX::NSLog "Removing log: #{item.basename}"
         item.unlink
      end
    end
  end
end


app_name = Pathstring.new(__FILE__).application_name  # Code here is same as used inside class
log_directory = Pathstring("~/Library/Logs/Ruby/#{app_name}").expand_path
log_directory.mkpath # Makes sure the path exists

logdir = Pathstring(log_directory)
clean_out_log_directory(logdir)


# Log
#
# Singelton class
#
# Usage: 
# require 'log'
# Log.debug "message"
#
# Important: This class can both be used as it is Log.debug 'message' and
# to produce separate log objects.
#
# Can be used both directly (Log.debug "Message")
# and to produce logs, local_log = Log(__FILE__) 
# or Log(__FILE__).debug "Message"
class Log #< OSX::NSObject
  include Log4r
  
  # Constants
    @@app_name = Pathstring.new(__FILE__).application_name
    @@formatter = PatternFormatter.new(:pattern => "%d [%5l] %m")  # Format for log entries
    @@rollover_time = 60*60*24    # 24 h in seconds.
    @@rollover_size = 100000
    # TODO: Should remove session logs from previous sessions (on class initiation or in setup)
    @@log_directory = Pathstring("~/Library/Logs/Ruby/#{@@app_name}").expand_path
    @@log_directory.mkpath # Makes sure the path exists
    
  # Class variables
    @@logs = {}

  # Class methods
  def Log.classlog(classref)
    return Log.new("Class: #{classref.name}") # Creates a log named 'Class:' + class name + .log
  end
  
  

  
  def initialize(logname = :default)  # (Normaly logname is a string. Tip: use __FILE__.)
    @logname = logname
    unless @@logs.has_key?(@logname)  # If there is alread a log with the name, use it
      setup_log
      setup_default if @logname == :default 
    end
  end
  
  def setup_log
    return if @@logs.has_key?(@logname)   # Log with this name already created and will be used.
    
    # OSX::NSLog("logname: #{@logname}")
    if @logname == :default
      log = Logger.new('default')
    else
      log = Logger.new(@logname)
    end
    
    # General output, a session log that collects all. TODO: Change format 
          # so that it's possible to see what log has written what.
      log.outputters << FileOutputter.new('output_all', :filename => (@@log_directory / "_all.log").to_s, :formatter => @@formatter)
      
    # General warnings. A warnings and errors log that all logs are writing to
      log.outputters << FileOutputter.new('output_warn', :filename => (@@log_directory / "WARNINGS & ERRORS.log").to_s, :formatter => @@formatter, :level => WARN )
      
    #log.outputters.each{|t| puts t.name}  # TEST
      
    # This log only.
      log.outputters << file_outputter
      
    # Send result also to stdout  TODO: Remove from unit test runs
    #  std = Outputter.stdout
    #  std.formatter = PatternFormatter.new(:pattern => "[%5l] %c :: %m")
    #  log.outputters << Outputter.stdout 
    
    # Save in class repository
      @@logs[@logname] = log   
  end
  
  def setup_default
    # Info output. Just the info messages from this log
      outputter = file_outputter
      outputter.level = INFO
    
    # Rolling log with INFO+
      @@logs[:default].outputters << RollingFileOutputter.new('output_rolling_info', :filename => (@@log_directory / "_info-rolling-.log").to_s, :trunc => false, :formatter => @@formatter, :maxsize => @@rollover_size, :level => INFO )
      (@@log_directory / "_info-rolling-.log").unlink     # Remove empty log (created but not used, as some kind of sideffect of 'maxsize')
  end

  # Outputters doc: http://log4r.sourceforge.net/rdoc/files/log4r/outputter/outputter_rb.html
    def file_outputter
      if @logname == :default
        id = ''
        filename = '_all'
      else
        id = "_#{@logname}"
        filename = @logname
      end

      # Making sure the directory exists.
      #     (Note: The logs are named after the files they are created in. So two identicaly named files (in
      #     different directories) will overwrite each others logs. )
      path_to_log = Pathstring(File.join(@@log_directory, File.basename(filename) + ".log"))
      d = path_to_log.dirname
      Pathstring(d).mkpath

      # OSX::NSLog "f: #{path_to_log}"

      # Creating outputter
      outputter = FileOutputter.new("output_all#{id}", :filename => (path_to_log).to_s, :formatter => @@formatter)
      return outputter
    end
      
  
  # Helper for Level-methods
  def Log.ensure_default_log
    Log.new(:default) unless @@logs.has_key?(:default)
  end

  # Level-methods
  def Log.debug(msg)
    Log.ensure_default_log
    @@logs[:default].debug(msg)
  end
  
  def Log.info(msg)
    Log.ensure_default_log
    @@logs[:default].info(msg)
  end
  
  def Log.warn(msg)
    Log.ensure_default_log
    @@logs[:default].warn(msg)
  end
  
  def Log.error(msg)
    Log.ensure_default_log
    @@logs[:default].error(msg)
  end
  
  def Log.fatal(msg)
    Log.ensure_default_log
    @@logs[:default].fatal(msg)
  end
  

  
  def debug(msg)
    @@logs[@logname].debug(msg)
  end
  
  def info(msg)
    @@logs[@logname].info(msg)
  end
  
  def warn(msg)
    @@logs[@logname].warn(msg)
  end
  
  def error(msg)
    @@logs[@logname].error(msg)
  end
  
  def fatal(msg)
    @@logs[@logname].fatal(msg)
  end 
  
  
  def get_log_object
    @@logs[:default]
  end
  
  # Extracts the message from the last log-line.
  # Primarily used for testing
  # TODO: Change to instance method, using conventional ways of identifying the log.
  require 'tommys_utilities'
  def Log.message_in_last_line_of_log(path)
    return Tommys_utilities::last_line_of_file(path).scan(/\[.*/)[0]
  end
  
end



