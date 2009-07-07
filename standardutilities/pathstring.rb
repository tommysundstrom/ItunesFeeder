#
#  Pathstring.rb
#  ItunesFeeder
#
#  Created by Tommy Sundstr‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö‚Ä†‚àö√°m on 25/2-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

require 'pathname'
require 'pp'
require 'osx/cocoa'
# require 'log'   WARNING since pathstring uses log, log can not be included here.



# Pathstring is a replacement for Pathname, that is a subclass to string. This way we get rid of the need
# to add to_s ever so often.
#
# Other differences:
#
# * It always expands ~-paths. 
# * Some extra utility classes.
#
class Pathstring < String
  #CLASSLOG = Log.new("Class: #{self.name}") # Creates a log named 'Class:' + class name + .log
  #CLASSLOG.debug "Loaded class '#{self.name}' from '#{__FILE__}'"

  def initialize(path)
    #CLASSLOG.debug "Creating '#{self.to_s} with path '#{path}'" # Use inside def initialize, to get object id

    # I'm not 100% about these two, so for the moment they'll have to go
    # path = File.expand_path(path) if path[0].to_s == '~' # Auto-expand ~-paths
    # path = File.expand_path(path) if path[0].to_s == '.' # Auto-expand paths anchored in present working directory
    
    self.replace(path.to_s)     # to_s in case it is a Pathname
    @pathname = Pathname.new(path)
  end
  
  def method_missing(symbol, *args)
    result = @pathname.__send__(symbol, *args)      # BUG BUG BUG   Ibland ger pathname andra sorters svar, t.ex. sant/falsk eller en array
          # N‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ¬¨¬®‚àö√ºr det inte ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ¬¨¬®‚àö√ºr en Pathname objekt jag f‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö√ë¬¨¬¢r tillbaka, m‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö√ë¬¨¬¢ste jag sl‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ¬¨¬®‚àö√ºppa vidare svaret som det ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ¬¨¬®‚àö√ºr (typ)
          # Fast ev kolla p‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö√ë¬¨¬¢ inneh‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö√ë¬¨¬¢llet i arrayen (t.ex. n‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ¬¨¬®‚àö√ºr det ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ¬¨¬®‚àö√ºr children, och Pathstringa dem.
    if result.class == Pathname then
      return Pathstring.new(result)
    elsif result.class == Array  then
      # If the members of the array is Pathnames, then they should be converted to Pathstrings
      return result.collect do |t|
        if t.class == Pathname then
          Pathstring.new(t)
        else
          t
        end
      end
    else
      return result # Other kinds of results are returned as they are
    end
  end

  def +(path)   # Overrides String behaviour.
    return Pathstring.new( (@pathname + Pathname.new(path)) )
  end

  
  
  # Differs from Pathname mkpath in that it also handles file paths
  def mkpath
    path = self.expand_path
    path = path.dirname if path.file? # Make sure the directory for the file exists
    Pathname(path).mkpath
  end

  # Differs from Pathname in that it will raise an error if first char of self is ~
  def exist?
    raise "Will not give a relevant answer for path '#{self}', since it starts with ~ and therefore by definition does not exist." if self[0..0] == '~'
    return File.exists?(self.to_s) 
  end
  
  
  # Added functions
    
  # Like Dir.mkdir, but without the error if a folder is already in place
  # The most common error is SystemCallError = The direcotry cannot be created
  def ANVANDS_EJensure_directory   # ANV‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬¥ND MKPATH IST‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬¥LLET!!!!
    #CLASSLOG.debug "Enters ensure_directory. self: #{self}"
    if self.exist? then 
      #CLASSLOG.debug "#{self} alredy existed"
      return  # Directory already in place, no need to do anything.  
    end 
    self.mkdir  
  end
  
  # Returns the path of the volume
  #   Quite Mac-centric I'm afraid
  def volume
    path_parts = self.split(/\//) # Split on forward slash
          # (Note that path_parts[0] is the empty string before the first '/'
    if path_parts[1] == "Volumes" then
        volume = Pathstring.new(path_parts[0..2].join('/')) # /Volumes/volumename
    else
        volume = Pathstring.new('/')  # /
    end
  end
  
  def rootvolume?
    return self.volume == '/' ? true : false
  end
  
  # Checks if a volume exists (i.e. is mounted)
    def mounted?
      return File.exists?(volume) ? true : false
    end
    
  # Cheks if two paths are on the same volume
    def same_volume?(path2)
      return volume == Pathstring.new(path2).volume ? true : false  # (Yes, I know this is tautologic; but it makes the code easer to read, at least for me)
    end
    
  # Moves the file. 
  # Unlike FileUtils.mv this can move across volumes. 
  # Can not move a directory
  ##def mv(destination)
  ##end


  # Returns a path to 'name' in self. self needs to be a directory.
  # If something with the same name is already present, adds a number to the name and tries again, until success or to many tries.
  def next_available_path_for(basename)  # TODO Let extension be a part of the name, split with ???
    if not self.directory? then raise "Can only add #{name} to a directory path." end

    # Splitting the basename into useful parts
    extname = File.extname(basename)  # (Includes the dot)
    name = File.basename(basename, extname) # Removes extname from basename

    new_path = self + (name + extname)
    #OSX::NSLog "Pathstring - self: #{self}"
    #OSX::NSLog "Pathstring - name: #{name}"
    #OSX::NSLog "Pathstring - new_path (i pathstring) pre: #{new_path}"
    # Check if there already is a fsitem with this path
    if new_path.exist?
      # Needs to change name, until I find something that is not already used
      for n in 1..9999 do
        new_path = self + (name + " %04d" % n + extname)   # adds for example 0012 to the name
        #OSX::NSLog "Pathstring - new_path (i pathstring): #{new_path}"
        #OSX::NSLog "Pathstring - n: #{n}"
        #OSX::NSLog "Pathstring - extname: #{extname}"
        if not new_path.exist?
          return Pathstring(new_path) # Returns a free name
        end
      end
      OSX::NSLog "Pathstring - WARNING: Unable to find a free name for '#{name}'."
      return false
    end
    return Pathstring(new_path)
  end 

  # Adds an extension
  def add_extension(ext)
    return Pathstring(self.to_s + '.' + ext)  
  end



  # Array of child-files and folders that to not begin their name with a dot
  def undotted_children
    self.children.reject {|t| t[0].to_s == '.' }
  end
  
  def children_that_match(array_of_regexps)
    # TODO:
  end
  
  def children_that_dont_match(array_of_regexps)
    # TODO:
  end
  
  # Array of child-files and folders that to not begin their name with a dot
  def children_except_those_beginning_with(array_of_beginnings)
    # NOT IMPLEMENTED YET self.children.select {|t| t[0].to_s != '.' }
  end

  # Array of child-files and folders that to not begin their name with a dot. Simpler version than that above
  def visible_children
    raise "Not implemented"
  end
  
  # Array of siblings (not including self)
  def siblings
    self.parent.children.reject {|t| t == self }
  end
  
  
  # Removes the extension from the basename
  # Counterpart to extname
  def basename_sans_ext
    return File.basename(self, self.extname)
  end
  
  # Removes the .DS_Store file - an autocreated file that just contains the visual settings 
  # for the folder - if there is one. Note that it may quickly be recreated by OSX. 
  # Mac-centric
  # I've had a great deal of trouble getting this to work reliably. (Theory: DS_Store was somehow
  # removed between the test and the unlinking.). But the rescue seams to fix that.
  def delete_dsstore!
    if (self + '.DS_Store').exist? then
      # OSX::NSLog "self: #{self}"
      # OSX::NSLog "(self + '.DS_Store').exist?: #{(self + '.DS_Store').exist?}"
      # OSX::NSLog "(self + '.DS_Store').to_s: #{(self + '.DS_Store').to_s}"
      begin
        File.unlink((self + '.DS_Store').to_s)
      rescue ArgumentError, e
        # Just continue
        # OSX::NSLog "Got an argument error when trying to remove the DS_Store-file"
        # OSX::NSLog "(self + '.DS_Store').exist?: #{(self + '.DS_Store').exist?}"
      end
    end
    return self
  end

  # For some reason, delete seams unreliable, while unlink works better. <- This may be a faulty conclusion,
  #     drawn from the problems with DS_Store. See above.
  def delete
    raise "For some reason, 'delete' seams unreliable, while 'unlink' works better. So use 'unlink' (at least until
            switching to Ruby 1.9)."
  end
  
  # Content of a directory, but with .DS_Store file excluded
  def children_sans_dsstore
    return self.children.reject{|t| t.basename == '.DS_Store'}
  end
  
  # Find the name for the application that contains this object
  #   Does this by finding the rb_main.rb-file in a Resource directory or the .app package.
  #   I'm not certain how robust this is. It's certainly RubyCocoa-centric.
  #   
  def application_name
    current = self.expand_path
    until current.root?
      if current.siblings.collect {|r| r.basename}.include?('rb_main.rb') then
        if current.parent.basename == 'Resources' && current.parent.parent.basename == 'Contents'
          # Part of an application bundle, applicationname.app
          OSX::NSLog "application_name (appbundle): #{current.parent.parent.parent.basename_sans_ext}"
          return current.parent.parent.parent.basename_sans_ext
        else
          # Assuming that we now are in the project folder, and that it is named like the app
          #OSX::NSLog "application_name (raw): #{current.parent.basename}"
          return current.parent.basename
        end
      end
      current = current.parent # Up one level for the next round in the loop
    end
    raise 'Unable to find an application name.'
  end
  
  # Array of the basenames of the children TROR DETTA REDAN ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬¥R T‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬¥CKT AV TYP Dir*
  def children_basename
  
  end
  
end

# This makes Pathstring(path) work as Pathstring.new(path)
#       TODO: Refactor the whole Pathstring module to Path
module Kernel
  # create a pathstring object.
  #
  def Pathstring(path) # :doc:
    # require 'pathstring'
    Pathstring.new(path)
  end
  
  def Path(path)
    Pathstring.new(path)
  end
  
  private :Pathstring
end
