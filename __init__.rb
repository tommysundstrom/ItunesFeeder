# Kind of Python-inspired. But outside instead of inside the folder.

App_root = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH << App_root

Standardutilities_root = File.join(File.dirname(File.expand_path(__FILE__)), 'standardutilities')
$LOAD_PATH << Standardutilities_root



=begin      Problem: Tests don't have this. Therefore, better let the files do the requiring themselves.
rbfiles = Dir.entries(Standardutilities_root).select {|x| /\.rb\z/ =~ x}
rbfiles.each do |path|
  require( File.basename(path) )
end
=end