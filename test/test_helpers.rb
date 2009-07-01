


module Test_helpers
  CLASSLOG = Log.new("Module: #{self.name}") # Creates a log named 'Class:' + class name + .log
  CLASSLOG.debug "Loaded module '#{self.name}' from '#{__FILE__}'"


  def cleanup_and_setup_workflow_dirs(testdir, video_archive)
    # Cleanup and setup directories for testing
    cleanup_workflow_dirs(testdir)
    setup_workflow_dirs(testdir, video_archive)
  end

  def cleanup_workflow_dirs(testdir)
    # Delete testdir (and everything in it)
    begin
      if testdir.exist?
        CLASSLOG.info "Removing the test dir at #{testdir}"
        FileUtils.rmtree([testdir], {:secure=>true}) # This will remove the dir including content. It's a bit
              # sensitive about permissions etc, see http://www.ruby-doc.org/core/classes/FileUtils.html#M004366
        raise "Failed to remove #{testdir}." if testdir.exist?
      else
        CLASSLOG.debug "No test dir at #{testdir} (so no need to remove it)."
      end
    end
  end

  def setup_workflow_dirs(testdir, video_archive)
    # Create a new testdir
    begin
      CLASSLOG.debug "Creating a new testdir at #{testdir.expand_path}"
      # Assuming that there is no such dir now
      raise "Failed to remove #{testdir}." if testdir.exist?
      FileUtils.mkdir(testdir)
      assert {testdir.exist?}
      CLASSLOG.info "Crated #{testdir} (used for testing)."
    end

    # Point the archive to testdir, and create the inbox and the processed dirs
    begin
      video_archive.set_workflow_paths(testdir) # paths
      video_archive.setup_archive_directories    # actual dir creation
      #@video_archive.set_processed = testdir
      #@video_archive.inbox = testdir + 'inbox'
    end
  end
end