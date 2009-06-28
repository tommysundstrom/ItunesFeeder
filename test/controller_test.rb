require "test/unit"
require 'rubygems'
require 'shoulda'
require 'assert2'

class ControllerTest < Test::Unit::TestCase

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
    end
  end
end