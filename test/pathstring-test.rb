#
#  pathstring-test.rb
#  ItunesFeeder
#
#  Created by Tommy Sundström on 25/2-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

#require 'test/unit' 
#require 'test-setup/testsetup'
#$log.info "RUNNING TEST: #{File.basename(__FILE__)}"
require 'pathname'
#require 'test-tools/util'
#require 'test-tools/stock-classes'

#require 'third-party/lib/pathstring.rb' # Makes little sens, but is the only workaround I've found

require 'test_setup'
require 'log'
###Log.debug "#{File.basename(__FILE__)} required."


# Något i den här knäcker rake-testen, som bara kraschar utan egentlig anledning.


class PathstringTests < Test::Unit::TestCase
  def setup
    # Log.debug "Sets up a #{File.basename(__FILE__)} test."
    #puts "HEJ HEJ"
    #$log.debug 'Enters PathstringTests'
    #$log.debug 'Det kanske är så enkelt att loggen lägger rabarber på stdout från test-rapporteringen.'
    #$log.info  'Eller det kanske inte är något fel? Fast det är det ju , jag ser fyra fel i raport-röda-krysset och på ikoen'
    @path_movies = '/Users/Tommy/Movies'
    @path_file_on_internal = '~/Movies/brotherhood.s02e04.hdtv.xvid-notv.[VTV].m4v'
    @path_file_on_wd = '/Volumes/WD/TORRENTS/02 Konverterade/brotherhood.s02e04.hdtv.xvid-notv.[VTV].m4v'
  end
  


  context "Basics." do
    should_eventually "Be a string" do
      # Something that tests that a subclass is a kind of superclass (String, Pathstring.new('abc') )
    end
    
    should "Create an object, with Pathstring() or Path() as well as Pathsring.new()" do
      assert_nothing_raised { Pathstring.new('abc') }
      assert_nothing_raised { Pathstring('abc') }
      assert_nothing_raised { Path('abc') }
    end
    
    context "Handling different types of input." do

      should "Understand the /-root" do
        assert { Pathstring.new('/') == '/' }
      end
      
      should "Understand the .-current directory" do
        assert { Pathstring.new('.') == '.' }
        assert { Pathstring.new('.').expand_path == Dir.pwd }
      end
      
      should "Understand the ../" do
        assert { Pathstring.new('../') == '../' }
        assert { Pathstring.new('../').expand_path == File.dirname(Dir.pwd) }
        assert { Pathstring.new(@path_file_on_wd) / '../' == File.dirname(@path_file_on_wd) }
      end
      
      should_eventually "NOT accept an empty input" do # This differs from Pathname
        assert_raise() { Pathstring.new() }
      end
      
      should "Not accept strange input." do
        assert_raise(TypeError) { Pathstring.new([]) }      
      end
      
      should_eventually "Gracefully handle when someone tries to dirpath etc. above the pwd" do # This differs from Pathname
      end
      
      should "Handle a single name" do
        assert { Pathstring.new('a directory or file name') == 'a directory or file name' }
      end
      
      should "Handle combined names" do
        assert { Pathstring.new('a/directory/or/file/name') == 'a/directory/or/file/name' }
        assert { Pathstring.new('a/directory/or/file/name').dirname == 'a/directory/or/file' }
      end
    end
    
    context "Adding paths together." do
      should "Add an root-absolute path correctly" do
        assert { Pathstring.new('foo/bar') / Pathstring.new('/Users') == '/Users' }
      end
    end
  end
  

  
  context "Core methods." do
    
    should "Behave like a string." do
      assert { @path_movies == '/Users/Tommy/Movies' }     # Funkar inte detta är hela poängen förlorad 
    end
    
    should "Return its parent." do
      assert { Pathstring.new(@path_movies).parent == '/Users/Tommy' }
    end
    
    should "Add paths like Pathname" do   # Like Pathname, not like String
      ps_sum = Pathstring.new('foo/bar') / Pathstring.new('/Users')
      pn_sum = Pathname.new('foo/bar') + Pathname.new('/Users')
      assert { ps_sum == pn_sum.to_s }
    end
    
    should "...and not like Strings" do   # Like Pathname, not like String
      ps_sum = Pathstring.new('foo/bar') / Pathstring.new('/Users')
      pn_sum = Pathname.new('foo/bar') + Pathname.new('/Users')
      deny { ps_sum == 'foo/bar' + '/Users' }
    end
  end
  
  context "File property and manipulation methods." do
    context "expand_path." do
      should "Expand path." do
        assert { Pathstring.new('~/Movies/brotherhood.s02e04.hdtv.xvid-notv.[VTV].m4v').expand_path == '/Users/Tommy/Movies/brotherhood.s02e04.hdtv.xvid-notv.[VTV].m4v'}
      end
    end
  end
  
  context "Volumes." do
    context "Path to." do
      should "Get the path to a internal volume" do
        assert { Pathstring.new(@path_file_on_internal).volume == '/' }
      end
      
      should "Get the path to an internal volume 2" do
        assert { Pathstring.new('/Library/Documentation/User Guides And Information.localized/AirPort Extreme Regulatory Certification.pdf').volume == '/' }
      end
      
      should "Get the path to a external volume" do
        assert { Pathstring.new(@path_file_on_wd).volume == '/Volumes/WD' }      
      end
    end
    
    context "Is the volume mounted?" do # Seams to be working, but deferred since I do not constantly have WD mounted.
      should_eventually "Tell if a volume is mounted -- THIS WILL ONLY WORK IF WD ACTUALLY IS MOUNTED" do
        assert { Pathstring.new(@path_file_on_wd).mounted? }
      end
      
      should "Tell if a volume is not mounted" do
        deny { Pathstring.new('/Volumes/noexisting_disc/TORRENTS/02 Konverterade/brotherhood.s02e04.hdtv.xvid-notv.[VTV].m4v').mounted? }
      end
    end
    
    context "Check if on the same volume." do
      should "Tell if files are on the same volume" do
        assert { Pathstring.new(@path_file_on_internal).same_volume?(@path_movies) }
      end
      
      should "Tell if files are NOT on the same volume" do
        deny { Pathstring.new(@path_file_on_wd).same_volume?(@path_movies) }
      end
      
      should "Tell if files are NOT on the same volume - when one volume is unmounted" do
        deny { Pathstring.new('/Volumes/noexisting_disc/TORRENTS/02 Konverterade/brotherhood.s02e04.hdtv.xvid-notv.[VTV].m4v').same_volume?(@path_movies) }
      end
    end
  end
  
  
  
  context "Directory content." do   # This partly duplicates tests for video_archive
    should "Not include dotted files in undotted_children" do
      assert { Pathstring.new(@path_movies).undotted_children.collect {|t| t.basename}.include?('.DS_Store') }
    end
    
    context "Remove .DS_Store -- " do
      setup do
        # Delete old files and directories
          if File.exist?(       '/Users/Tommy/Programmering/Ruby/Unittest tmp') then
            FileUtils.remove_dir( '/Users/Tommy/Programmering/Ruby/Unittest tmp')
          end
  
        # Set preference folders
          preferences = Preferences.new
          preferences.register_defaults_for_inbox('/Users/Tommy/Programmering/Ruby/Unittest tmp/iTunes-inbox')
          preferences.register_defaults_for_processed('/Users/Tommy/Programmering/Ruby/Unittest tmp')

        # Create the archive (and some folders)
          @video_archive = Video_archive.new(preferences)
          @video_archive.setup_archive_directories
          
        # Some folders that will come in handy
          @failed    = Pathstring.new('/Users/Tommy/Programmering/Ruby/Unittest tmp/_failed')
          @m4ved     = Pathstring.new('/Users/Tommy/Programmering/Ruby/Unittest tmp/_m4ved')
          @originals = Pathstring.new('/Users/Tommy/Programmering/Ruby/Unittest tmp/_originals')
          @unsupported = Pathstring.new('/Users/Tommy/Programmering/Ruby/Unittest tmp/_unsupported')
      end
      
      should_eventually "Delete unneded directories with cleanup_archive_directories" do
        assert_nothing_raised { @video_archive.cleanup_archive_directories }
      end
    end
      
  end
  
  context "Application name." do
    should_eventually "Be able to extract the application name when runned from rake" do
      assert { Pathstring.new(__FILE__).application_name == 'FlatTemplate' }
    end
    
    should "Extract application name from a file in the application, when given the unit-test path." do
      assert_nothing_raised { Pathstring.new('/Users/Tommy/Programmering/Ruby/Projekt/FlatTemplate/Pathstring.rb') }
      assert_nothing_raised { Pathstring.new('/Users/Tommy/Programmering/Ruby/Projekt/FlatTemplate/Pathstring.rb').application_name }
      assert { Pathstring.new('/Users/Tommy/Programmering/Ruby/Projekt/FlatTemplate/Pathstring.rb').application_name == 'FlatTemplate' }
    end
  end
end
