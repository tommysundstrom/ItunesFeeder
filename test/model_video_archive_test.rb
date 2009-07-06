require 'test_setup'

require 'fileutils'
require 'model_video_archive'
require 'controller_preferences'
require 'log'
require 'test_helpers'

class Video_archive_Test < Test::Unit::TestCase
  CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
  CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"
  CLASSLOG.debug "Creating '#{self.to_s}'" # Use inside def initialize, to get object id

  include Test_helpers # Provides cleanup_and_setup_workflow_dirs


  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @rblog = Log.new(__FILE__)
    CLASSLOG.debug "Running #{self.to_s}."
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
          CLASSLOG.debug assert { @video_archive.eyeball(p) == :ignore }
        end

        should "...and items starting with an underscore" do
          p = Pathname.new('')
          p = Pathname.new('~/Users/Tommy/_Starts with an underscore')
          assert { @video_archive.eyeball(p) == :ignore }
        end
      end
    end
  end


  context "Creating directories for the archive - " do
    setup do
      @video_archive = Video_archive.new(Preferences.new)
      @testdir = Pathstring('~/Programmering/Ruby/Projekt/ItunesFeeder_test/workflow').expand_path # WARNING This dir and
            # its content will be removed.

      CLASSLOG.debug "Removing old a creating new, empty, workflow dirs."
      cleanup_and_setup_workflow_dirs(@testdir, @video_archive) # included from Test_helpers

    
    end

    should "All archive directories should exist" do
      assert { @video_archive.inbox.exist? }
      assert { @video_archive.processed.exist? }
      assert { @video_archive.originals.exist? }
      assert { @video_archive.unsupported.exist? }
      assert { @video_archive.failed.exist? }
      assert { @video_archive.m4ved.exist? }
    end

    should "Clean up empty directories" do
      assert_nothing_raised { @video_archive.cleanup_archive_directories }
      deny { @video_archive.originals.exist? }
      deny { @video_archive.unsupported.exist? }
      deny { @video_archive.failed.exist? }
      deny { @video_archive.m4ved.exist? }
    end
                 
    context "Paths - " do
      should "Setup archive directories" do
        assert_nothing_raised { @video_archive.setup_archive_directories }
        assert { @video_archive.inbox.exist? }
        assert { @video_archive.inbox == @testdir + 'inbox' }
        assert { @video_archive.processed.exist? }
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
    end

    context "With example files - " do
      setup do
        @examples = Pathstring(File.dirname(@testdir)) + 'examples'        
      end

=begin
      context "A - " do        
        setup do
          # Copy testfiles into place
          @example_folder = 'A'
          example = @examples + @example_folder
          FileUtils.copy_entry(example, @video_archive.inbox, :remove_destination => true)
        end

        teardown do
          result_archive = @examples + (@example_folder.to_s + ' - result')
          FileUtils.rmtree([result_archive], {:secure=>true})
          result_archive.mkdir
          FileUtils.copy_entry(@video_archive.inbox.dirname, result_archive, :remove_destination => true)
        end

        should "Process the file" do
          assert_nothing_raised { @video_archive.process_inbox }
        end

        context "Processed - " do
          setup do
            @video_archive.process_inbox
          end
          
          should "All archive directories should exist" do
            assert { @video_archive.inbox.exist? }
            assert { @video_archive.processed.exist? }
            assert { @video_archive.originals.exist? }
            assert { @video_archive.unsupported.exist? }
            assert { @video_archive.failed.exist? }
            assert { @video_archive.m4ved.exist? }
          end
          
          should "Handle when Handbrake fails with a file." do
            assert { (@video_archive.failed + 'Dummy.Sons.of.Anarchy.S01E13.The.Revelator.HDTV.XviD-FQM.avi').exist? } 
          end
        end
      end
=end

      context "avi - " do
        setup do
          # Copy testfiles into place
          @example_folder = 'avi'
          example = @examples + @example_folder
          FileUtils.copy_entry(example, @video_archive.inbox, :remove_destination => true)
        end

        teardown do
          result_archive = @examples + (@example_folder.to_s + ' - result')
          FileUtils.rmtree([result_archive], {:secure=>true})
          result_archive.mkdir
          FileUtils.copy_entry(@video_archive.inbox.dirname, result_archive, :remove_destination => true)
        end

        should "Process the file" do
          assert_nothing_raised { @video_archive.process_inbox }
        end

        context "Processed - " do
          setup do
            @video_archive.process_inbox
          end

          should "All archive directories should exist" do
            assert { @video_archive.inbox.exist? }
            assert { @video_archive.processed.exist? }
            assert { @video_archive.originals.exist? }
            assert { @video_archive.unsupported.exist? }
            assert { @video_archive.failed.exist? }
            assert { @video_archive.m4ved.exist? }
          end

          should "Convert the file to m4v." do
            assert { (@video_archive.m4ved + 'avi-Helgmalsringning.m4v').exist? }
          end

          should "Move the original to the processed folder" do
            assert { (@video_archive.originals + 'avi-Helgmalsringning.avi').exist? }            
          end
        end
      end

    end
  end
end