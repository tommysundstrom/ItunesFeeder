require 'test_setup'

require 'fileutils'
#require 'model_video_archive'
#require 'controller_preferences'
#require 'log'

class Model_video_Test < Test::Unit::TestCase
  CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
  CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"

  def setup
    #require 'model_video'
    CLASSLOG.debug "Running #{self.to_s}."
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  context "video.rb - " do
    should_eventually "Initialize" do
      assert_nothing_raised { Video.new(file) }
    end

    context "Class methods - " do
      should "Clean up yucky file names" do
        original_clean = {
                'In.Treatment.S01E32.HDTV.XviD-2HD' => 'In Treatment s01e32',
                'In.Treatment.S01E35.HDTV.XviD-XOR.avi' => 'In Treatment s01e35',
                'In.Treatment.S01E36.HDTV.XviD-2HD.avi' => 'In Treatment s01e36',
                'Pushing Daisies 104.avi' => 'Pushing Daisies s01e04',
                'The New Adventures of Old Christine s01e06.m4v' => 'The New Adventures of Old Christine s01e06',
                'The Sarah Jane Adventures S01E05 Warriors of the Kudlak Part 1 [MM].avi' => 'The Sarah Jane Adventures s01e05 Warriors of the Kudlak Part 1',
                'The Sarah Jane Adventures S01E06 Warriors of Kudlak Part 2 [MM].avi' => 'The Sarah Jane Adventures s01e06 Warriors of Kudlak Part 2',
                'True.Blood.S02E01.HDTV.XviD-NoTV' => 'True Blood s02e01',
                'True.Blood.S02E03.HDTV.DVDrip.[AC3_2009].ENG-DUQA.avi' => 'True Blood s02e03',
                'Trust.Me.S01E03.HDTV.XviD-0TV.avi' => 'Trust Me s01e03',
                'Trust.Me.US.S01E04.HDTV.XviD-aAF.avi' => 'Trust Me US s01e04',
                'Dummy.Sons.of.Anarchy.S01E13.The.Revelator.HDTV.XviD-FQM.avi' => 'Dummy Sons of Anarchy s01e13 The Revelator'
                }
        eventually = {      # Do not (yet) have the right code to clean these.
                'The.Cleaner.1x01.2008.SPANISH.HDTV.XviD.[www.BajandoSeries.com].avi' => 'The Cleaner s01e01',
                      # Problems: year and spanish. Both can match things in title.
                      # Solution: Try finding the season-episode, and match stuff like this if it comes after. Not
                      #       a 100% secure solution though. 
                'Primeval.S01E03-Episode 3.avi' => 'Primeval.S01E03',
                'Star.Wars.Clone.Wars.Volume.2.XviD.avi' => 'Star Wars - Clone Wars - Volume.2',
                '' => '',
                '' => '',
                }
        directories = {      # Don't know if there will be any need to clean these up
                'Mad_Men_Season1.rar' => '???',  # How do I want it to look???
                'Pushing Daisies Season 1 DVDRip' => '???',
                'TRUE_BLOOD_SEASON1_DISC4.ISO' => '',
                '' => '',
                '' => '',
                }
        original_clean.each do |key, value|
          video = Video.new(key)    # This is not a functioning file-path but for the purpose of this exercise it does
                # not matter)
          assert { video.clean_name == value  }  
        end
        # assert { Video.clean_name() ==  }
      end
    end

    context "Video archive object - " do
      setup do
        @video_archive = Video_archive.new(Preferences.new)
      end
    end
  end
end