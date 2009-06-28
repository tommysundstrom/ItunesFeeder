#---
# Excerpted from "RubyCocoa",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/bmrc for more book information.
#---
# Load this file to adjust paths to use gems and libraries
# from the sandbox. Use Apple-supplied gems, but nothing in 
# user_gems. Strip load path back down to starting value.
#
# This is not for use in Apps. 

require 'rbconfig'  # Needed for some versions

module Sandbox
  SANDBOX='sandbox'

  def self.locations
    here = Dir.pwd
    while !File.exist?(File.join(here, SANDBOX))
      here += "/.."
    end
    ['lib', 'gems'].collect { | subdir | File.join(here, SANDBOX, subdir) }
  end

  def self.install_pristine_load_path
    # Following line leaves a spurious /Library/Ruby/Site in the load
    # path. That's harmless.
    $:.delete_if { | p | p =~ Regexp.new(RbConfig::CONFIG['sitedir']) }
    ENV['RUBYLIB'].split(':').each do | path |
      $:.delete(path)
    end if ENV.has_key?('RUBYLIB')
  end

  def self.adjust_load_path(new_sitelibdir)
    install_pristine_load_path
    $: << new_sitelibdir
  end
    

  def self.adjust_gem_path(new_sitelibdir, new_sitegemdir)
    require 'rubygems'
    Gem::ConfigMap[:sitelibdir] = new_sitelibdir
    ENV['GEM_HOME'] = new_sitegemdir
    ENV.delete('GEM_PATH')
    Gem.use_paths(ENV['GEM_HOME'], [APPLE_GEM_HOME, ENV['GEM_HOME']])
  end

  def self.add_to_gem_path(dir)
    Gem.path << dir
  end
end

libdir, gemdir = Sandbox.locations
Sandbox.adjust_load_path(libdir)
Sandbox.adjust_gem_path(libdir, gemdir)

=begin
puts "Running in: #{Dir.pwd}"
puts "$: " 
puts $:
puts "GEM paths"
puts Gem.path
=end
