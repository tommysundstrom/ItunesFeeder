#
#  Video.rb
#  AutoHandbrake
#
#  Created by Tommy Sundström on 8/2-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

# A file with video contents
class Video
  CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
  CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"

  attr_reader :file, :basename, :extension, :name
  attr_accessor :prefered_name

  def initialize(file)
    CLASSLOG.debug "Creating '#{self.to_s}'." # Use inside def initialize, to get object id
    CLASSLOG.debug "Initializing #{self.to_s}."
    
    @file = Pathname.new(file)  # TODO: Make sure the file is not growing (= is currently written)
    @basename = @file.basename
    @extension = @file.extname # Extension _including_ initial dot.
    @name = File::basename(@file.to_s, @extension) # Basename without extension.
    @prefered_name = clean_name # This might later be changed by handlers.

    # Metadata
    @title = extract_title
  end

  # Filename without extension, and with a lot of the typical torrent cruft removed. Dotts replaced by spaces.
  def clean_name(name = @name)
    # Remove cruft
    begin
      cruft = [ "HDTV", "LOL", "Parabolmannen", "SweSub", "VTV", "XviD-.*", "XviD", "ws",
                "pdtv", "DVDrip", "AC3_2008", "AC3_2009", "AC3_2010", "AC3_2011", "AC3_2012",
                "ENG-DUQA", "MM" ]  # Stuff that we want to remove from the name
      CLASSLOG.debug "name: #{name}"
      nameparts = name.split(/\./)
      CLASSLOG.debug "nameparts: #{'<' + nameparts.join('> <') + '>'}"
      cruftfree_nameparts = nameparts[1..-1].select {|p| cruft.select {|c| /^\[?#{c}\]?$/i.match(p)} == [] }
          # (Keep (=select) those nameparts where matching aginst the cruft list comes up empty)
          # First item of the name is always protected
          # Regexp:   ^..$ -  must match entire
          #           \[? and \]? - match also if enclosed with brackets
          #           #{c} - cruft
          #           //i - ignore case
      clean_name = ([nameparts[0]] + cruftfree_nameparts).join(".")

      # Site names
      clean_name = clean_name.gsub(/\[www\..*?\.com\]/, '')  # Matches things like '[www.BajandoSeries.com]'

      # Special cases. One-offs etc.
      begin
        clean_name = clean_name.gsub(/ \[MM\]$/, '')
      end 

      # Remove dots
      clean_name = clean_name.gsub(/\./,  ' ')

      # Fix season & episode numbering
      begin
        # Lower case for season and episode
        clean_name = clean_name.gsub(/ S(\d\d)E(\d\d)/, ' s\1e\2')

        # Fix numbering like '104'
        clean_name = clean_name.gsub(/ (\d)(\d\d)$/, ' s0\1e\2')  # (Will only fix it if it is 3 numbers at
              # the end of the name.)

        # Fix numbering like  '1x04'
        clean_name = clean_name.gsub(/ (\d)x(\d\d)$/, ' s0\1e\2')  # (Will only fix it if it is 3 numbers at
              # the end of the name.)
      end
      clean_name = clean_name.strip
    end

    CLASSLOG.info "Cleaned up '#{name}' to '#{clean_name}'"
    return clean_name
  end

  # Move (and possibly rename) the file that this object represents
  #
  # moveto - can be a directory or a full filename
  #
  # TODO: Check if destination is on other drive. In that case, make copy there and delete original (once the copy is confirmed).
  #
  # It's generally a bit confused with the target, target_file etc stuff. It should be refactored away. 
  def move_me(target, the_basename = @basename)
    target = Pathstring.new(target)
    Log.debug("Move #{file.basename} to #{target}")

    # Make it a full path
    if target.directory? then # (When moveto is a file path, then no changes are made to it.)
      target_file = target / the_basename
    else
      target_file = target
    end

    # Make sure the target directory exists
    Log.debug "Making sure all directories for #{target_file} exists."
    # File.makedirs(target) # Make sure the directory exists   makedirs comes in 1.9??
    if not target_file.dirname.exist? then raise "Target directory for #{target_file} is missing" end   # Temp solution

    # Make sure there does not already exist a file with the same name
    if target_file.exist? then
      new_target_file = target_file.parent.next_available_path_for(target_file)
      CLASSLOG.info "'#{target_file}' already exist in '#{target_file.parent}', so renaming original file to '#{new_target_file}'."
      target_file = new_target_file
      # Log.warn "A file with that name already exists (#{target_file})."
      # return # Aborts   TODO: ev rename etc.
    end

    # Make the move
    Log.debug "Moves #{@basename} to #{target_file}."
    @file.rename(target_file)

    # Internal bookkeeping
    @file = target_file
    @extension = @file.extname
    @basename = @file.basename # Note, the file may have been renamed in the move
    @name = File::basename(@file.to_s, @extension)
  end

  # Moves the file using the prefered_name
  def move_and_clean_me(target)
    target = Pathstring(target)
    CLASSLOG.debug "Clean #{file.basename} and move to #{target.next_available_path_for(@prefered_name + @extension)}"
    move_me(target, target.next_available_path_for(@prefered_name + @extension))
  end

  # Tell iTunes to add the file
  #
  # Note: iTunes may (depending on its settings) move the file, making this object lose track of it.
  # (There is however a track id number returned, making it possible to see it inside iTunes.)
  def add_me_to_iTunes
    ITunes::add_file(@file)
    # Borde filen flyttas först, till ett särskilt directory för det som är importerat???
    #
    # TODO: Check if file is still in location. If not, destroy self.
  end

  # Tries to extract a title from the file name
  def extract_title
    title = prefered_name
    # TODO: If this realy is needed, fix it
  end
end
