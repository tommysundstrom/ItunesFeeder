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
          @testdir = Pathstring('~/Programmering/Ruby/Projekt/ItunesFeeder_test/workflow').expand_path # WARNING This dir and
              # its content will be removed.
          @examples = Pathstring(File.dirname(@testdir)) + 'examples'
          @example_folder = 'controller_test_A'   

                  
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
    
        should "Empty inbox once" do
          @c.empty_inbox_once('dummyvalue')
        end

        # For test of watching, see should "Watch inbox" in watch_inbox_testloop


      end

      context "With conflikting content in inbox - " do
        setup do
          require 'model_video_archive'
          @testdir = Pathstring('~/Programmering/Ruby/Projekt/ItunesFeeder_test/workflow').expand_path # WARNING This dir and
              # its content will be removed.
          @examples = Pathstring(File.dirname(@testdir)) + 'examples'
          # @example_folder = 'duplicate file name'


          CLASSLOG.debug "Removing old a creating new, empty, workflow dirs."
          cleanup_and_setup_workflow_dirs(@testdir, @c.video_archive) # included from Test_helpers

          # Copy testfiles into place
          example_inbox = @examples + 'duplicate file name' + 'in inbox'
          FileUtils.copy_entry(example_inbox, @c.video_archive.inbox, :remove_destination => true)

          example_m4v = @examples + 'duplicate file name' + 'in m4v'
          FileUtils.copy_entry(example_m4v, @c.video_archive.m4ved, :remove_destination => true)

          #
          #@c.video_archive.set_inbox(@video_archive.inbox)    # This is stupid
          #@video_archive.set_processed_and_subfolders
        end

        teardown do
=begin
          result_archive = @examples + (@example_folder.to_s + ' - result')
          FileUtils.rmtree([result_archive], {:secure=>true})
          result_archive.mkdir
          FileUtils.copy_entry(@c.video_archive.inbox.dirname, result_archive, :remove_destination => true)
=end
        end

        should "Find an alternative name, if the prefered name is already taken" do
          m4v_dir = Pathstring('/Users/Tommy/Programmering/Ruby/Projekt/ItunesFeeder_test/workflow/processed/_m4ved')
          prefered_file_name = 'm4v-Helgmalsringning.iPodBest.m4v'
          CLASSLOG.debug "Prefered file name: #{prefered_file_name}"
          new_path = m4v_dir.next_available_path_for(prefered_file_name)
          CLASSLOG.debug "Available file name: #{File.basename(new_path)}"
          CLASSLOG.debug "new_path: #{new_path}"
          assert {File.basename(new_path) == 'm4v-Helgmalsringning.iPodBest 0001.m4v'}
          assert {File.dirname(new_path) == m4v_dir}
        end
                           
        
      end
    end
  end
end