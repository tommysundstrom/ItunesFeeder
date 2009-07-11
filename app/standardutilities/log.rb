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
###require 'log4r/outputter/syslogoutputter'
require 'log4r/outputter/emailoutputter'

# I've tried using the SyslogOutputter, but there is to many strange effects from it. Instead I've worked around it
# by using OSX::NSLog



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
#
# Note. There is a email logger in here that may or may not function properly. My intent is to replace
# it with something using Mail.app.
class Log #< OSX::NSObject
  include Log4r
  
  # Constants
  @@app_name = Pathstring.new(__FILE__).application_name
  @@formatter = PatternFormatter.new(:pattern => "%d [%5l] %m")  # Format for log entries
  @@rollover_time = 60*60*24    # 24 h in seconds.
  @@rollover_size = 100000
  @@log_directory = Pathstring("~/Library/Logs/Ruby/#{@@app_name}").expand_path
  @@log_debug_directory = @@log_directory / '_debug'
  @@log_debug_directory.mkpath # Makes sure the path exists (in the process also ensuring the path for @@Log_directory)
  ###WARN = 3    # For some reason require 'log4r/outputter/syslogoutputter' destroys these three values
  ###ERROR = 4
  ###FATAL = 5
  ###@@syslog = SyslogOutputter.new('output_syslog_all_info') #, :level => INFO)
  ###@@syslog.close

  SYSLOG_LEVEL = 2 # = INFO-level
    
  # Class variables
  @@logs = {}

  # Class methods
  def Log.classlog(classref)
    log = Log.new("Class: #{classref.name}") # Creates a log named 'Class:' + class name + .log
    log.debug "Loaded class '#{classref.name}' " # from '#{classref.__FILE__}'"
    return log
    # There is also an instance method, init, to be used in the initialize method of the class.
  end
  
  

  #
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
    
    # Logs for whole application
    #     A session log that collects all. TODO: Change format so that it's possible to see what log has written what.
    log.outputters << FileOutputter.new('output_all', :filename => (@@log_debug_directory / "_all.log").to_s, :formatter => @@formatter)
    #     One that collollects all info and higher (TODO This should also go into the general system log
    log.outputters << FileOutputter.new('output_all_info', :filename => (@@log_directory / "_all.log").to_s, :formatter => @@formatter, :level => INFO)
    #     Dito, rolling
    log.outputters << RollingFileOutputter.new('output_rolling_info', :filename => (@@log_directory / "_all-rolling-.log").to_s, :trunc => false, :formatter => @@formatter, :maxsize => @@rollover_size, :level => INFO )
    (@@log_directory / "_all-rolling-.log").unlink     # Remove empty log (created but not used, as some kind of sideffect of 'maxsize')
    #     Dito, to syslog
    ###log.outputters << @@syslog
    ###SyslogOutputter.close
    ###log.outputters << SyslogOutputter.new('output_syslog_all_info', :level => INFO)
    #     General warnings. A warnings and errors log that all logs are writing to
    log.outputters << FileOutputter.new('output_all_warn', :filename => (@@log_directory / "__WARNINGS & ERRORS.log").to_s, :formatter => @@formatter, :level => WARN )

    #log.outputters.each{|t| puts t.name}  # TEST
      
    # Logs for this specific log only
    log.outputters = log.outputters + file_outputter
      
    # Send result also to stdout  TODO: Remove from unit test runs
    #  std = Outputter.stdout
    #  std.formatter = PatternFormatter.new(:pattern => "[%5l] %c :: %m")
    #  log.outputters << Outputter.stdout 
    
    # Save in class repository
    @@logs[@logname] = log   
  end

  # Adds email to a log
  def add_email_log
    @@logs[@logname].outputters << EmailOutputter.new('email_out',    # TODO (8) Make GUI for these prefs
                     :server=>'heltenkelt.se',
                     :port=>25,
                     :domain=>'heltenkelt.se',
                     :from=>'itunesfeeder@heltenkelt.se',
                     :to=>'tommy@heltenkelt.se',
                     :subject=>'Report from iTunesFeeder')
  end
  
  def setup_default
    # Info output. Just the info messages from this log
    ##outputter = file_outputter
    ##outputter.level = INFO
    
    # Rolling log with INFO+
      ##@@logs[:default].outputters << RollingFileOutputter.new('output_rolling_info', :filename => (@@log_directory / "_info-rolling-.log").to_s, :trunc => false, :formatter => @@formatter, :maxsize => @@rollover_size, :level => INFO )
      ##(@@log_directory / "_info-rolling-.log").unlink     # Remove empty log (created but not used, as some kind of sideffect of 'maxsize')
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
    @@log_debug_directory.mkpath
    #log_path = Pathstring(File.join(@@log_directory, File.basename(filename) + ".log"))
    #log_dir =
    #log_debug_dir =
    #d = log_path.dirname
    #Pathstring(d).mkpath

    # OSX::NSLog "f: #{path_to_log}"

    # Creating outputter
    outputters = []
    #   For everything
    outputters << FileOutputter.new("output_all#{id}", :filename => (@@log_debug_directory / (File.basename(filename) + '.log')).to_s, :formatter => @@formatter)
    #   For info and higher
    outputters << FileOutputter.new("output_info#{id}", :filename => (@@log_directory / (File.basename(filename) + '.log')).to_s, :formatter => @@formatter, :level => INFO)
    #outputter = FileOutputter.new("output_all#{id}", :filename => (log_path).to_s, :formatter => @@formatter)
    return outputters
  end

  # Flushes all outputters (most important for the email outputter, but it does not hurt the other ones.
  # Class method (have not method for flushing individual log instances.
  # ATT GÖRA : FLUSHA I SLUTET AV PROCESSA INBOX (OM DET VARIT NÅGOT DÄR)
  # OCH LÄGG TILL EMAILLOGGEN PÅ NÅGON LOGG (SKAPA EN SPECIELL?)
  def Log.flush
    Outputter.each_outputter {|outp| outp.flush}
  end

  # Helper functions to be used with a classlog, (first) in the initialize method.
  def init(obj)
    @@logs[@logname].debug "Creating '#{obj.to_s}'." # Use inside def initialize, to get object id
  end

  # Helper for Level-methods
  def Log.ensure_default_log
    Log.new(:default) unless @@logs.has_key?(:default)
  end

  # Level-methods
  def Log.debug(msg)
    Log.ensure_default_log
    @@logs[:default].debug(msg)
    OSX::NSLog '(DEBUG) ' + msg if SYSLOG_LEVEL == DEBUG
  end
  
  def Log.info(msg)
    Log.ensure_default_log
    @@logs[:default].info(msg)
    OSX::NSLog '( INFO) ' + msg if SYSLOG_LEVEL <= INFO
  end
  
  def Log.warn(msg)
    Log.ensure_default_log
    @@logs[:default].warn(msg)
    OSX::NSLog '( WARN) ' + msg if SYSLOG_LEVEL <= WARN
  end
  
  def Log.error(msg)
    Log.ensure_default_log
    @@logs[:default].error(msg)
    OSX::NSLog '(ERROR) ' + msg if SYSLOG_LEVEL <= ERROR
  end
  
  def Log.fatal(msg)
    Log.ensure_default_log
    @@logs[:default].fatal(msg)
    OSX::NSLog '(FATAL) ' + msg if SYSLOG_LEVEL <= FATAL
  end
  

  
  def debug(msg)
    @@logs[@logname].debug(msg)
    OSX::NSLog '(DEBUG) ' + msg if SYSLOG_LEVEL == DEBUG
  end
  
  def info(msg)
    @@logs[@logname].info(msg)
    OSX::NSLog '( INFO) ' + msg if SYSLOG_LEVEL <= INFO
  end
  
  def warn(msg)
    @@logs[@logname].warn(msg)
    OSX::NSLog '( WARN) ' + msg if SYSLOG_LEVEL <= WARN
  end
  
  def error(msg)
    @@logs[@logname].error(msg)
    OSX::NSLog '(ERROR) ' + msg if SYSLOG_LEVEL <= ERROR
  end
  
  def fatal(msg)
    @@logs[@logname].fatal(msg)
    OSX::NSLog '(FATAL) ' + msg if SYSLOG_LEVEL <= FATAL
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



