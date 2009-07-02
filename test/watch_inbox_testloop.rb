require 'test_setup'
require 'test_helpers'

# This will start watching the inbox for changes.
# It should not be included in the normal test-run, since it would just stop here, watching the inbox
# for ever (or until an error occures).
class Watch_inbox_Test < Test::Unit::TestCase
  CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
  CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"
  CLASSLOG.debug "Creating '#{self.to_s}'" # Use inside def initialize, to get object id

  include Test_helpers # Provides cleanup_and_setup_workflow_dirs
  
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    CLASSLOG.debug "Creating '#{self.to_s}'" # Use inside def initialize, to get object id
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

    context "Controller object - " do
      setup do
        @c = Controller.new
      end

      context "With content in inbox - " do
        setup do
          require 'model_video_archive'
          @testdir = Pathstring('~/Programmering/Ruby/Projekt/ItunesFeeder_test/workflow').expand_path # WARNING This dir and
              # its content will be removed.
          @examples = Pathstring(File.dirname(@testdir)) + 'examples'   # Realy belongs to the first child context,
                # but for some reason it works better here. OR NOT
          @example_folder = 'controller_test_A'    # dito

                  
          CLASSLOG.debug "Removing old a creating new, empty, workflow dirs."
          cleanup_and_setup_workflow_dirs(@testdir, @c.video_archive) # included from Test_helpers

          # Copy testfiles into place
          example = @examples + @example_folder
          FileUtils.copy_entry(example, @c.video_archive.inbox, :remove_destination => true)

          #
          #@c.video_archive.set_inbox(@video_archive.inbox)    # This is stupid
          #@video_archive.set_processed_and_subfolders
        end

        teardown do
          result_archive = @examples + (@example_folder.to_s + ' - result')
          FileUtils.rmtree([result_archive], {:secure=>true})
          result_archive.mkdir
          FileUtils.copy_entry(@c.video_archive.inbox.dirname, result_archive, :remove_destination => true)
        end

        should "Watch inbox" do
          # IMPORTANT This is a endless loop (until application quits - so it's not appropriate to have during
          #     normal testing.
          @c.watch_inbox('dummyvalue')          
        end
      end
    end
  end
end