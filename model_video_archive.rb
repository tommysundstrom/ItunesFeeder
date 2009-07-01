#
#  Video_archive.rb
#  AutoHandbrake
#
#  Created by Tommy Sundström on 8/2-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

require 'pathstring'
require 'fileutils'
require 'external_handbrake'
require 'model_video'

# A video_archive is a collection of videos (and some other files)
#
# The files are in different states, represented by different directories. (It is not mandatory for these directories to
# be in the same place. Though, for technical reasons they need to be on the same volume.)
#
# inbox     - The in-basket. Videos that are to be processed. Often also contains files that are not video. Often a video
#             is a folder.
#               Assumption: All videos are directly in the folder. Some of them may consist of a folder with its content,
#             but there is no need to recurse into folders.
# processed - The unaltered files from pending goes here, once they are processed. (In the future there
#             will be an option to send them directly to trash.)
# m4ved     - Videos that has been converted to m4v (suitable for iTunes)
# failed    - Videos that we could not process.
class Video_archive
  # TODO include Send_mail
  CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
  CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"
  CLASSLOG.debug "Creating '#{self.to_s}'." # Use inside def initialize, to get object id

  attr_reader :inbox, :processed, :originals, :unsupported, :failed, :m4ved

  def initialize(preferences)
    @rblog = Log.new(__FILE__)
    CLASSLOG.debug "Initializing #{self.to_s}."
    CLASSLOG.debug "Creating '#{self.to_s}'." # Use inside def initialize, to get object id

    set_inbox(preferences.inbox)
    set_processed_and_subfolders(preferences.processed)
    # TODO: Option to trash after iTunes has imported (in that case, this should be a temp directory inside inbox)
  end

  # Setting paths for folders in workflow
  begin
    def set_inbox(inbox_path)
      @inbox      = Pathstring.new(inbox_path)
    end

    def set_processed_and_subfolders(processed_path)
      # Possibly erronious thinking - should this not be set in the prefereces object??
      #   (That way I belive they may be persistent???)
      @processed  = Pathstring.new(processed_path)
      #@current    = @processed + 'current'    # Normaly just contains max one file or directory - the one currently being worked on
      @originals  = @processed + '_originals'  # TODO: Option to move to Trash + option to delete directly
      @unsupported = @originals + '_unsupported'
      @failed     = @originals + '_failed'     # Directory to put the files Handbrake could not do anything about in
      @m4ved      = @processed + '_m4ved'      # Directory to take the files Handbrake creates.
    end

    def set_workflow_paths(path)   # Utilities method that points to a root workflow/'ItunesFeeder' dir, and inside that
            # an inbox and a processed dir.
      path = Pathstring(path)
      set_inbox(path + 'inbox')
      set_processed_and_subfolders(path + 'processed')
    end
  end

  # Walks the archive, analyzing the files in it and processing them.
  #
  # Assumption: All videos are directly in the folder. Some of them may consist of a folder with its content. But there
  # is no need to recurse into folders.
  #
  # TODO: Byt från 'each' till att alltid ta första objektet i foldern. Eftersom det alltid flyttas bort, blir resultatet
  # detsamma, men den blir mindre känslig för att saker läggs till/tas bort. Ev. Flytta saken under arbete till en särskild arbetsfolder (för att minska risken att någon stryker den medan man jobbar på den.
  def empty_inbox # Check that inbox and the other directories exists, and create if not

    # Check that the volume exists (= is mounted)
    unless @inbox.mounted?      # TODO: BUG verkar inte varna även när WD saknas.
      Log.warn "Volume containing '#{@inbox}' not found."
      return
    end

    setup_archive_directories

    process_inbox

    cleanup_archive_directories
  end



  # Preparatons

  # Process inbox
  def process_inbox
    CLASSLOG.debug "Checking the inbox (at '#{@inbox}')."

    # First have a quick lookthrough and sort away the items that can not be video files.
    interesting_children = @inbox.children.reject {|t| eyeball(t) == :ignore || eyeball(t) == :not_video }

    CLASSLOG.debug "Number of items in inbox: #{interesting_children.length}"
    CLASSLOG.info "--- Emptying the inbox (#{interesting_children.length} items) ---" unless interesting_children.length == 0

    interesting_children.each do |inp|
      # TODO: Handle changes in the folder while this loop is running (since it involves Handbreaking files, it can run for hours).
      CLASSLOG.debug "Analyzing #{inp}"

      if inp.directory?
        # Handle videos that are in the form of a directory

        # Removing uninteresting files and directories
          candidates = inp.children # OSV OSV

        # Check so that the folder does not contain multiple objects that could be videos.
          video_extensions = [".m4v", ".avi", "" ]

        # Check so there is not a (possible) hierarchy of directories

        # Identify and handle rar-archives


        #
        failed_handler(inp, "Can't handle folders yet.")
        next

        # Kom ihåg:
        # * Foldernamnet oftast intressantare än filnamnet
        # * Ev. intressant behålla bildmaterial, subs etc.

      elsif inp.file?
        # Make it into a Video object
          video = Video.new(inp)

        # Find a handler
          if video.extension == ".m4v" then
            passtrough_with_cleaned_name_handler(video) # Already in the correct format.
            next
          end

        # If no special case was found, use the general_handler
          general_handler(video)
          next

      else
        raise "Unknown type: #{inp.to_s}"
        # TODO: Handle links and aliases
      end

      # TODO: For all move - hadle duplicate files (check FileUtils, maybe it has a solution already)
      # TODO: Enclose all in try, and move those that triggers an error to a special folder
    end
    ###@classlog.info "... Inbox is emptied ..."
  end

  # Gives a preliminary view of what to do with a file or dir, so that the uninteresting ones
  # can be filtered out.
  #
  # Returns one of:
  # :ignore
  # :not_video
  # :analyze
  #
  def eyeball(inp)
    # Do nothing with invisible (dotted) files, and items starting with an underscore
      first_character = inp.basename.to_s[0,1]
      if first_character == "." or first_character == "_" then return :ignore end

    # Branding files that are not video (or just samples)
      ignored_folders = ["Sample", "Subs"]
      if ignored_folders.include?(inp.basename.to_s) then
        ###@classlog.debug "#{inp.basename} was not (interesting) video."
        return :not_video
      end

      ignored_files = ["Sample.avi"]
      if ignored_files.include?(inp.basename.to_s) then   # TODO: Rexexp so that it works with any Sample.xxx extension
        ###@classlog.debug "#{inp.basename} was just not (interesting) video."
        return :not_video
      end

    # Ignore some extensions
      ignored_extensions = [".nfo", ".sfv", ".txt", ".jpg"]
      if ignored_extensions.include?(inp.extname) then
        ###@classlog.debug "#{inp.basename} was not video."
        return :not_video
      end

    return :analyze
  end

  # Handlers
  begin
    # Handles all the simple chases (those that are in a format Handbrake can handle)
    # (Undrar om jag i detta (och liknande) borde kolla att filen inte växer
    # - dvs håller på att kopieras. Tycker fillåset borde ta hand om den saken,
    # men vem vet.
    def general_handler(video)
      CLASSLOG.info "general_handler is handling #{video.basename}"
      # TODO: This (and some other) should take some seconds to check that the file is not still growing.
      m4v_video = Handbrake::feed_me(video, @m4ved)
      if m4v_video then
        video.move_me(@originals) # Move the processed file.
        # Todo TILLFALLIGT BORTKOPPLAD   m4v_video.add_me_to_iTunes
        ### send_email('no-reply@heltenkelt.se', 'iTunes Feeder', 'tommy@heltenkelt.se', 'Tommy Sundström', "#{m4v_video.name} added to iTunes", '')
        # Skriv in konverterad fil i särskild logg. Skicka ett mail eller publicera RSS.
        # TODO: 2-3 min paus if conversion took more than 10 min.
      else
        # Handbrake failed to convert the file
        video.move_me(@failed)
      end
    end

    def passtrough_with_cleaned_name_handler(video)
      CLASSLOG.info "passtrough_with_cleaned_name_handler is handling #{video.basename}"
      video.move_and_clean_me(@m4ved) # Since the file is already in the right format, it is just moved
            # to the output directory. No copy is made to @processed. Name is cleaned up.
      # Todo TILLFALLIGT BORTKOPPLAD   video.add_me_to_iTunes
    end

    # Stuff we can't handle is moved to failed
    def failed_handler(inp, reason)
      CLASSLOG.info "Failed to do anything with #{inp.basename}, except moving it to #{@failed}"
      CLASSLOG.info "This is why: #{reason}"
      FileUtils.move(inp, @unsupported + inp.basename) # TODO: Handle overwrites
    end
  end


  # Checks if all needed directories exists, and creates them if not
  begin
    def setup_archive_directories
      CLASSLOG.info "Verifying or creating inbox at '#{@inbox}'"
      @inbox.mkpath
      CLASSLOG.debug "Inbox in place"

      CLASSLOG.info "Verifying or creating processed at '#{@processed}'"
      @processed.mkpath
      #@current.mkpath
      @originals.mkpath
      @m4ved.mkpath
      @unsupported.mkpath
      @failed.mkpath

      CLASSLOG.debug "Exits setup_archive_directories"
    end

    def cleanup_archive_directories
      CLASSLOG.info "Removing empty processed directories"
      @unsupported.rmdir   if @unsupported.delete_dsstore!.children.length == 0
      @failed.rmdir        if @failed.delete_dsstore!.children.length == 0
      @originals.rmdir     if @originals.delete_dsstore!.children.length == 0 # Note: needs to be removed *after*
            # the two dirs above (that resides *inside* originals).
      @m4ved.rmdir         if @m4ved.delete_dsstore!.children.length == 0
      @processed.rmdir     if @processed.delete_dsstore!.children.length == 0 # Note: must be removed last

    end
  end
end


