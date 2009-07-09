#
#  rb_main.rb
#  ItunesFeeder
#
#  Created by Tommy Sundström on 27/6-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

require 'osx/cocoa'
require 'pp' # TEST
# OSX::NSLog "Running rb_main.rb"

def rb_main_init
  OSX::NSLog "rb_main_init" # TEST
=begin  # Moved to rb_main_tommys_extra_init  $LOAD_PATH << File.dirname(File.expand_path(__FILE__)) # TEST
  $LOAD_PATH << File.dirname(File.join(File.dirname(File.expand_path(__FILE__)), 'standardutilities')) # TEST
  pp $LOAD_PATH
  

  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
=end

  rb_main_tommys_extra_init
end

def rb_main_tommys_extra_init
  OSX::NSLog "Orignal rb_main.rb extended with some additons by Tommy"  

  # Require and load files Python init-style
  #context = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation # The resource dir of the app. (This
        # is always (?) the dir where this file (rb_main.rb) is.)
  #context_dir =  context # File.dirname(context)
  context = __FILE__
  context_dir = File.dirname(context)
  OSX::NSLog "context: #{context}"

  add_to_load_path_if_has_init(context_dir)
  require_if_in_dir_with_init(context_dir)
end

# Recursivly processes the init files - first pass, add all dirs with __init__ to the load_path
#
# For the moment, the existence of a init-file adds the dir to load-path and makes all the rb-files to be required.
# First pass should handle load_path, second requirement).
def add_to_load_path_if_has_init(context_dir)
  raise "'#{context_dir}' does not seam to exist." unless File.exist?(context_dir)
  raise "Must be a directory." unless File.directory?(context_dir)

  if File.exist?(context_dir + '/__init__.rb')
    # There is a __init__.rb file in this directory.
    # TODO: Check for a 'special' method in it, that can be used to adjust the handling

    $LOAD_PATH << context_dir

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
def require_if_in_dir_with_init(context_dir)
  raise "'#{context_dir}' does not seam to exist." unless File.exist?(context_dir)
  raise "Must be a directory." unless File.directory?(context_dir)

  if File.exist?(context_dir + '/__init__.rb')
    # There is a __init__.rb file in this directory.
    # TODO: Check for a 'special' method in it, that can be used to adjust the handling

    # Require all .rb-files, except __init__.rb and rb_main.rb (ie this file)
    rbfiles = Dir.entries(context_dir).select {|x| /\.rb\z/ =~ x}
    OSX::NSLog "All rbfiles in '#{context_dir}':"
    rbfiles.each {|item| OSX::NSLog item}
    rbfiles -= [ '__init__.rb' ] # Ignore any file named '__init__.rb'
    rbfiles -= [ File.basename(__FILE__) ] # Ignore any file named 'rb_main.rb'
    rbfiles.each do |basename|
      OSX::NSLog "controller.rb spotted" if basename == 'controller.rb'
      require( File.basename(basename, '.rb')) # requires file name, without rb extension. (This is the most usual
            # way to require, so I do this in order to avoid double-requirements.)
    end


    # Recursively do the same with sub-folders
    Dir.entries(context_dir).select do |basename|
      basename[0..0] != '.' and File.directory?(File.join(context_dir, basename))
    end.each do |dir| # i.e. for each directory in context_dir
      path = File.join(context_dir, dir)
      require_if_in_dir_with_init(path)
    end
  end
end

if $0 == __FILE__ then
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
