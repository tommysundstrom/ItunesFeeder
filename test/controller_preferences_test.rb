require 'test_setup'

class Controller_preferences_Test < Test::Unit::TestCase
  CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name
  # .log
  CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"
  CLASSLOG.debug "Creating '#{self.to_s}'" # Use inside def initialize, to get object id

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    CLASSLOG.debug "Initializing #{self.to_s}."
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  context "controller_preferences.rb - " do
    setup do
      require 'controller_preferences'
    end

    should "Initialize" do
      assert_nothing_raised { Preferences.new }  
    end

    context "Preferences object" do
      setup do
        @pref = Preferences.new
      end

      should "Have a inbox path" do
        assert {@pref.inbox == '/Users/Tommy/Movies/iTunes-inbox'}
      end

      should "Have a processed path" do
        assert { @pref.processed == '/Users/Tommy/Movies/iTunes-processed' }
      end
    end
  end
end