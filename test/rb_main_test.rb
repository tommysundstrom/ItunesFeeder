require "test/unit"
require 'rubygems'
require 'shoulda'
require 'assert2'

require 'osx/cocoa'

class Rb_main_Test < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    $LOAD_PATH << File.dirname(File.dirname(__FILE__))  # Since rb_main is located outside the application dir
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
    should "Dummytest" do
    end
    
    should_eventually "Initialize the application"  do  # seams that path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
            # is not pointing to the application dir when I run a test (at least not when using Test::Unit to start it)
      OSX::NSLog "Initializing"
      assert_nothing_raised { rb_main_init }
    end
  end
end