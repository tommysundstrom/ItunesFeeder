require "test/unit"
require 'rubygems'
require 'shoulda'
require 'assert2'

class Controller_preferences_Test < Test::Unit::TestCase

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