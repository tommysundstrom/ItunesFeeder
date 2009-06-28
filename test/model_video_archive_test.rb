#require "test/unit"
#require 'rubygems'
#require 'shoulda'
#require 'assert2'

require 'test_setup'

require 'fileutils'
require 'model_video_archive'
require 'controller_preferences'
require 'log'

class Model_video_archive_Test < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @rblog = Log.new(__FILE__)
    @rblog.debug "Running #{self.to_s}."
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  context "model_video_archive.rb - " do
    should "Initialize" do
      assert_nothing_raised { Video_archive.new(Preferences.new) }
    end

    context "Video archive object - " do
      setup do
        @video_archive = Video_archive.new(Preferences.new)
      end

      context "Eyeballing a file - " do
        should "Do nothing with invisible (dotted) files" do
          p = Pathname.new('~/Users/Tommy/.DS_Store')
          @rblog.debug assert { @video_archive.eyeball(p) == :ignore }
        end

        should "...and items starting with an underscore" do
          p = Pathname.new('')
          p = Pathname.new('~/Users/Tommy/_Starts with an underscore')
          assert { @video_archive.eyeball(p) == :ignore }
        end
      end
    end
  end


  context "Creating directories for the archive" do
    setup do
      @video_archive = Video_archive.new(Preferences.new)
      @testdir = Pathstring('~/Programmering/Ruby/Projekt/ItunesFeeder_test').expand_path # WARNING This dir and
            # its content will be removed.

      # Delete testdir (and everything in it)
      begin
        if @testdir.exist?
          @rblog.info "Removing the test dir at #{@testdir}"
          FileUtils.rmtree([@testdir], {:secure=>true}) # This will remove the dir including content. It's a bit
                # sensitive about permissions etc, see http://www.ruby-doc.org/core/classes/FileUtils.html#M004366
          raise "Failed to remove #{@testdir}." if @testdir.exist?
        else
          @rblog.debug "No test dir at #{@testdir} (so no need to remove it)."
        end
      end

      # Create a new testdir
      begin
        @rblog.debug "Creating a new testdir at #{@testdir.expand_path}"
        # Assuming that there is no such dir now
        raise "Failed to remove #{@testdir}." if @testdir.exist?
        FileUtils.mkdir(@testdir)
        #assert {@testdir.exist?}
        @rblog.info "Crated #{@testdir} (used for testing)."
      end
    end

    should "Setup archive directories" do
      assert_nothing_raised { @video_archive.setup_archive_directories }
    end

    should "Recognize when a volume is non-existant" do
      deny { Pathstring.new('/Volumes/Noneexistant/dir/dir/inbox').mounted? }
    end

    should "Recognize when a volume exists" do
      assert { Pathstring.new(File.expand_path('~/Music')).mounted? }
    end

    #should "Log if the path to the inbox is incorrect (or maybe not mounted for the moment)" do
    #  assert { @video_archive.volume_exists?('/System/Volumes/Noneexistant/dir/dir/inbox' == false) }
    #end

    should "Validate or create the needed folders" do
    end
      

  end




end