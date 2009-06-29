#
#  Handbrake.rb
#  AutoHandbrake
#
#  Created by Tommy Sundstršm on 8/2-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

require 'open3' # http://tech.natemurray.com/2007/03/ruby-shell-commands.html


# Feeds files into Handbrake
  #
  # inp - Path to the file that are to be processed
  # convertedp - Directory to put the output from Handbrake in
  # processedp - Directory to put the (unaltered) original files in, when they are processed by Handbrake
  #
  # Returns the video that was created
class Handbrake
    CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
    CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"
    CLASSLOG.debug "Creating '#{self.to_s}'." # Use inside def initialize, to get object id

    def self.feed_me(video, converted, type = :normal) # TODO: Settings for :animated
    CLASSLOG.debug "Feeding '#{video.basename}' to Handbrake."

    # Get names
      #inp_name = File::basename(inp.to_s, File::extname(inp.to_s))
      out_path = Pathstring.new(converted) + (video.prefered_name + ".m4v")

    # Check that the file does not already exist
      if out_path.exist? then
        CLASSLOG.warn "#{out_path} exists already, so cannot process #{video.basename}."
        # raise # TODO: fix this and handler for it
        return
      end

    # Feed it to Handbrake
      CLASSLOG.info "Feeding '#{video.file.basename}' to Handbrake"
      stdin, stdout, stderr = Open3.popen3("HandBrakeCLI -i \"#{video.file}\" -o \"#{out_path}\"  --ipod-atom -e x264 -q 0.59 -9 -5 -a 1 -E faac -B 128 -R 48 -6 dpl2 -f mp4 -X 480 -x level=30:cabac=0:ref=2:mixed-refs:analyse=all:me=umh:no-fast-pskip=1")
          # Note: Handbrake gives its essential results through stderr
          # and uses stdout to report progress.
      #Log.info "Handbrake result: \n#{stderr.read}"
      #stderr.rewind

      # Log.debug "Handbrake stdout:  #{stdout.read}"

        # K€NNS INTE HELT HUNDRA. KANSKE VORE DET B€TTRE ATT IST€LLET KOLLA OM RUSULTATFILEN DYKT UPP
      lines = []
      result = ''
      stderr.each_line{|line| lines << line}
      CLASSLOG.debug "Original no of lines: #{lines.length}"
      while lines.length > 0 do
        lastline = lines.pop.strip
        CLASSLOG.debug "Checking line #{lines.length + 1}: '#{lastline}'"
        if lastline == 'HandBrake has exited.' then
          # Result is reported on the line before this one
          result = lines.pop.strip
          break
        end
      end

      case result
        when 'Rip done!'
          # Make a video object of the converted file, to feed into iTunes
          CLASSLOG.info "Rip done!"
            m4v_video = Video.new(out_path)
          # ...and feed it to iTunes
          return m4v_video
        when 'No title found.'
          # Handbrake did not manage to convert the file.
          CLASSLOG.warn "Failed to convert #{video.file.basename}"
          return false
        when ''
          CLASSLOG.warn "No result. Never found 'HandBrake has exited'"
          return false
        else
          raise "HandBrake returned unknown result: #{result}"
      end

    # TODO: Send a message that the conversion has been done (by mail?)
  end

  # Removes the extension from a filename
  # file - must be a path or a filename with an extension
  def basename_without_extension(file)
    return File::basename(file.to_s, File::extname(file.to_s))
  end
end
