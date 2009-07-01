require 'test_setup'
require 'test_helpers'

class ControllerTest < Test::Unit::TestCase
  CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
  CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"
  CLASSLOG.debug "Creating '#{self.to_s}'" # Use inside def initialize, to get object id

  include Test_helpers # Provides cleanup_and_setup_workflow_dirs
  
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @rblog = Log.new(__FILE__)
    @rblog.debug "Initializing #{self.to_s}."
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  context "Controller - " do
    setup do
      require 'controller'
    end
    
    should "Initialize." do
      assert_nothing_raised { Controller.new }  
    end

    context "Controller object - " do
      setup do
        @c = Controller.new
        @c.setup_preferences
      end

      should "Call awakeFromNib." do
        assert_nothing_raised { @c.awakeFromNib }        
      end


      should "Empty inbox (without anything) once" do
        @c.empty_inbox_once('dummyvalue')
      end

      context "With content in inbox - " do
        setup do
          require 'model_video_archive'
          @video_archive = Video_archive.new(Preferences.new)

          @testdir = Pathstring('~/Programmering/Ruby/Projekt/ItunesFeeder_test/workflow').expand_path # WARNING This dir and
              # its content will be removed.
          @examples = Pathstring(File.dirname(@testdir)) + 'examples'   # Realy belongs to the first child context,
                # but for some reason it works better here. OR NOT
          @example_folder = 'controller_test_A'    # dito

                  
          CLASSLOG.debug "Removing old a creating new, empty, workflow dirs."
          cleanup_and_setup_workflow_dirs(@testdir, @video_archive) # included from Test_helpers

          # Copy testfiles into place
          example = @examples + @example_folder
          FileUtils.copy_entry(example, @video_archive.inbox, :remove_destination => true)

          #
          @video_archive.set_inbox(@video_archive.inbox)    # This is stupid
          #@video_archive.set_processed_and_subfolders
        end

        teardown do
          result_archive = @examples + (@example_folder.to_s + ' - result')
          FileUtils.rmtree([result_archive], {:secure=>true})
          result_archive.mkdir
          FileUtils.copy_entry(@video_archive.inbox.dirname, result_archive, :remove_destination => true)
        end

        

        should "Empty inbox once" do
          @c.empty_inbox_once('dummyvalue')
        end
      end
    end
  end
end