# Functions for adding app dir and any subfolder to $LOAD_PATH and loading all rb files in them.
#
# Assumes that all application files are in the app dir

require 'osx/cocoa'
require 'rubygems'  # (not used here, but will probably come in useful in a lot of places.


#OSX::NSLog "require_app_files loaded" # TEST

module Require_app_files
  NAMEBODYS = []   # Used to check aginst duplicate names.

  # Add app-dir and all its sub-dirs to $LOAD_PATH
  def Require_app_files.add_to_load_path(context_dir)
    raise "'#{context_dir}' does not seam to exist." unless File.exist?(context_dir)
    raise "Must be a directory." unless File.directory?(context_dir)

    $LOAD_PATH << context_dir   # TODO (9) Add mechanism for excluding a dir (maybe by adding a __not_in_loadpath__
          # file to it.
    OSX::NSLog "Added '#{context_dir}' to $LOAD_PATH"

    # Recursively do the same with sub-folders
    begin
      Dir.entries(context_dir).select do |basename|
        basename[0..0] != '.' and File.directory?(File.join(context_dir, basename))
      end.each do |dir| # i.e. for each directory in context_dir
        path = File.join(context_dir, dir)
        add_to_load_path(path)
      end
    end 
  end

  # Requires standardutilites (so that ordinary rb files does not have to think about requiering them)
  def Require_app_files.require_standardutilities
    # Assumes that 'add_to_load_path' has been runned
    require 'log'
    require 'pathstring'
  end

  # Recursively require all rb files
  def Require_app_files.require_all(context_dir)
    raise "'#{context_dir}' does not seam to exist." unless File.exist?(context_dir)
    raise "Must be a directory." unless File.directory?(context_dir)

    # Require all .rb-files
    begin
      rbfiles = Dir.entries(context_dir).select {|x| /\.rb\z/ =~ x}
      # rbfiles -= [ '__init__.rb' ] # Ignore any file named '__init__.rb'
      # Paths in rbfiles are loacal, but as long as every dir is added to LOAD_PATH it is not needed to change working dir.
      OSX::NSLog "Requiring rb-files inside '#{context_dir}':"  # TEST
      rbfiles.each do |basename|
        OSX::NSLog "namebodys: #{NAMEBODYS.to_a}" # TEST
        namebody = File.basename(basename, '.rb')
        OSX::NSLog "namebody: #{namebody}" # TEST
        if NAMEBODYS.index(namebody) == nil  
          NAMEBODYS << namebody
        else
          # This name is already in array
          raise "Duplicate filename '#{basename}'."
        end
        result = require(namebody) # requires file name, without rb extension. (This is the most usual
              # way to require, so I do this in order to avoid double-requirements.)
        OSX::NSLog "  Required '#{namebody}'#{if result == false then ' (but it had apparently already been required)' end}." # TEST
      end
      OSX::NSLog '---'  # TEST
    end 

    # Recursively do the same with sub-folders
    begin
      Dir.entries(context_dir).select do |basename|
        basename[0..0] != '.' and File.directory?(File.join(context_dir, basename))
      end.each do |dir| # i.e. for each directory in context_dir
        path = File.join(context_dir, dir)
        require_all(path)
      end
    end 
  end
  
end  