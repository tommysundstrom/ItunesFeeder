# Adds dirs with __init__ to $LOAD_PATH, and requires the files in them.

require 'osx/cocoa'

#OSX::NSLog "require_app_files loaded" # TEST

module Require_app_files

  # Returns the dir where the application files are located.
  #
  # There are two alternatives for the location of application files and subdirectories:
  # in a 'app' dir, that is a sibbling to rb_main.rb, or in the same directory as rb_main.rb.
  #
  # top_dir should be the directory containing rb_main.rb
  def Require_app_files.application_files_directory(top_dir)
    raise "'top_dir' must be the direcotry containing rb_main.rb" unless File.exist?(File.join(top_dir, 'rb_main.rb'))
    
    if File.exist?(File.join(top_dir, 'app'))
      OSX::NSLog "Assuming that all application files are placed in the 'app' directory."
      return File.join(top_dir, 'app')
    else
      OSX::NSLog "Assuming that all application files are placed in the same dir as rb_main.rb"
      return top_dir
    end

  end

  # Recursivly processes the init files - first pass, add all dirs with __init__ to the load_path
  #
  # For the moment, the existence of a init-file adds the dir to load-path and makes all the rb-files to be required.
  # First pass should handle load_path, second requirement).
  def Require_app_files.add_to_load_path_if_has_init(context_dir)
    raise "'#{context_dir}' does not seam to exist." unless File.exist?(context_dir)
    raise "Must be a directory." unless File.directory?(context_dir)

    if File.exist?(context_dir + '/__init__.rb')
      # There is a __init__.rb file in this directory.
      # TODO: Check for a 'special' method in it, that can be used to adjust the handling

      $LOAD_PATH << context_dir
      OSX::NSLog "Added '#{context_dir}' to $LOAD_PATH"

      # Recursively do the same with sub-folders
      Dir.entries(context_dir).select do |basename|
        basename[0..0] != '.' and File.directory?(File.join(context_dir, basename))
      end.each do |dir| # i.e. for each directory in context_dir
        path = File.join(context_dir, dir)
        add_to_load_path_if_has_init(path)
      end
    end
  end

  # Recursively process init files - second pass, require rb files
  def Require_app_files.require_if_in_dir_with_init(context_dir)
    raise "'#{context_dir}' does not seam to exist." unless File.exist?(context_dir)
    raise "Must be a directory." unless File.directory?(context_dir)

    if File.exist?(context_dir + '/__init__.rb')
      # There is a __init__.rb file in this directory.
      # TODO: Check for a 'special' method in it, that can be used to adjust the handling

      # Require all .rb-files, except __init__.rb and rb_main.rb (ie this file)
      rbfiles = Dir.entries(context_dir).select {|x| /\.rb\z/ =~ x}
      #OSX::NSLog "All rbfiles in '#{context_dir}':"
      #rbfiles.each {|item| OSX::NSLog item}
      rbfiles -= [ '__init__.rb' ] # Ignore any file named '__init__.rb'
      rbfiles -= [ File.basename(__FILE__) ] # Ignore any file named 'rb_main.rb'
      # TODO: IMPORTANT: Must change working dir. (Remember it and restore it at root level.)
      # CORRECTION As long as every dir is added to LOAD_PATH it is not needed.
      OSX::NSLog "Requiring rb-files inside '#{context_dir}':"
      rbfiles.each do |basename|
        result = require( File.basename(basename, '.rb')) # requires file name, without rb extension. (This is the most usual
              # way to require, so I do this in order to avoid double-requirements.)
        OSX::NSLog "  Required '#{basename}'#{if result == false then ' (but it had apparently already been required)' end}."
      end
      # OSX::NSLog '---'



      # Recursively do the same with sub-folders
      Dir.entries(context_dir).select do |basename|
        basename[0..0] != '.' and File.directory?(File.join(context_dir, basename))
      end.each do |dir| # i.e. for each directory in context_dir
        path = File.join(context_dir, dir)
        require_if_in_dir_with_init(path)
      end
    end
  end
end  