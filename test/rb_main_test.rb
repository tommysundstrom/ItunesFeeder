require "test/unit"
require 'rubygems'
require 'shoulda'
require 'assert2'

require 'osx/cocoa'

class Rb_main_Test < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  context "rb_main.rb - " do
    setup do
      require 'rb_main'
    end
    should "Initialize the application"  do
      OSX::NSLog "Initializing"
      assert_nothing_raised { rb_main_init }
    end
  end
end