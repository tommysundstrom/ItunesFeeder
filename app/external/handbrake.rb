#
#  Handbrake.rb
#  AutoHandbrake
#
#  Created by Tommy Sundstr�m on 8/2-09.
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
    CLASSLOG.debug "Creating '#{self.to_s}." # Use inside def initialize, to get object id

    def self.feed_me(video, converted_path, type = :normal) # TODO: Settings for :animated
      if converted_path.exist? then raise "There already is a file at #{converted_path}." end # This should never happen.

      # Feed it to Handbrake
      CLASSLOG.info "Feeding '#{video.file.basename}' to Handbrake"
      # test = "HandBrakeCLI -i \"#{video.file}\" -o \"#{converted_path}\"  --ipod-atom -e x264 -q 0.59 -9 -5 -a 1 -E faac -B 128 -R 48 -6 dpl2 -f mp4 -X 480 -x level=30:cabac=0:ref=2:mixed-refs:analyse=all:me=umh:no-fast-pskip=1"
      stdin, stdout, stderr = Open3.popen3("HandBrakeCLI -i \"#{video.file}\" -o \"#{converted_path}\"  --ipod-atom -e x264 -q 0.59 -9 -5 -a 1 -E faac -B 128 -R 48 -6 dpl2 -f mp4 -X 480 -x level=30:cabac=0:ref=2:mixed-refs:analyse=all:me=umh:no-fast-pskip=1")
      CLASSLOG.debug "Handbrake returned after processing '#{video.file.basename}'."   
          # Note: Handbrake gives its essential results through stderr
          # and uses stdout to report progress.
      #Log.info "Handbrake result: \n#{stderr.read}"
      #stderr.rewind

      # Start analyzing Handbrake output
      lines = []
      result = ''
      stderr.each_line{|line| lines << line}

      # First of all, check that there now is a file at converted_path
      if not converted_path.exist?
        CLASSLOG.warn "Handbrake failed to convert '#{video.file}' into '#{converted_path}'."
        CLASSLOG.warn "--- This is what Handbrake reported: ---"
        lines.each {|line| CLASSLOG.warn line}
        CLASSLOG.warn "----------------------------------------"
        return false
      else
        # An output file has been created. But still need to check Handbrake output.

        while lines.length > 0 do
          lastline = lines.pop.strip # (stderr is read from last line to first)     
          CLASSLOG.debug "Checking line #{lines.length + 1}: '#{lastline}'"
          if lastline == 'HandBrake has exited.' then
            # Result is reported on the line before this one
            result = lines.pop.strip
            CLASSLOG.debug "HandBrake result: #{result}"
            break
          end
        end

        case result
          when 'Rip done!'
            # Make a video object of the converted file, to feed into iTunes
            CLASSLOG.info "Rip done!"
            m4v_video = Video.new(converted_path)
            # ...and feed it to iTunes
            return m4v_video
          when 'No title found.'
            # Handbrake did not manage to convert the file.
            CLASSLOG.warn "No title found - failed to convert #{video.file.basename}"
            return false
          when ''
            CLASSLOG.warn "No result. Never found 'HandBrake has exited'"
            return false
          else
            CLASSLOG.error "HandBrake returned unknown result: #{result}"
            raise "HandBrake returned unknown result: #{result}"
        end
      end

    # TODO: Send a message that the conversion has been done (or failed) (by mail?)
  end

  # Removes the extension from a filename
  # file - must be a path or a filename with an extension
  def basename_without_extension(file)
    return File::basename(file.to_s, File::extname(file.to_s))
  end
end
