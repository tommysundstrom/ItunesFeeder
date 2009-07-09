#
#  preferences.rb
#  ItunesFeeder
#
#  Created by Tommy Sundstršm on 25/2-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

require 'osx/cocoa'


class Preferences < OSX::NSObject
  CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
  CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"
  CLASSLOG.debug "Creating '#{self.to_s}'" # Use inside def initialize, to get object id

  def init
    super_init

    @defaults = OSX::NSUserDefaults.standardUserDefaults
    register_defaults_for_inbox('~/Movies/iTunes-inbox')   # Note: The directory for the box
          # will not be created until the program is actually run, so the user can change inbox location in the preferences.
    register_defaults_for_processed( Pathstring.new(@defaults.objectForKey(:inbox)).parent / 'iTunes-processed' ) # This is the location
          # of directories for files that has been processed, converted, failed, etc. Must be on the same volume!

    return self
  end

  # Checks that inbox and processed directories are on the same volume
  # (since we want to be able to move these big files, not copy them)
  # Potential BUG: What happens if I want to move both to a diffent volume. Maybe there should be a method for moving
  #    both at the same time..?
  def register_defaults_for_processed(target_dir)
    if Pathstring.new(inbox).volume == Pathstring.new(target_dir).volume then
        @defaults.registerDefaults(:processed => Pathstring.new(target_dir) )
    else
      raise "Both inbox and processed directories must be on same volume."
    end
  end

  # Checks that inbox and processed directories are on the same volume
  def register_defaults_for_inbox(inboxpath)
    if processed then # If there is a default set for processed...
      if not Pathstring.new(inboxpath).volume == Pathstring.new(processed).volume then # ...and it's not on the same volume as inboxpath
        raise "Both inbox and processed directories must be on same volume."
      end
    end
    @defaults.registerDefaults(:inbox => File.expand_path(inboxpath))
  end

  #def set_preferences
  #end

  # Note that this points to the actual inbox-directory
  def inbox
    return @defaults.objectForKey(:inbox)
  end

  # But this points to a directory that will contain a set of different directories for processed files
  def processed
    return @defaults.objectForKey(:processed)
  end
end
