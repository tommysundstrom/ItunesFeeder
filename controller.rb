require 'osx/cocoa'
require 'log'

puts '--- LOAD_PATH i controller.rb ---'
puts $LOAD_PATH
puts '------'




class Controller < OSX::NSObject
  include OSX

  def init
    super_init
    @rblog = Log.new(__FILE__)
    @rblog.debug "Initializing #{self.to_s}."

    return self
  end

  def awakeFromNib # Note: this is called also when the interface is defined from a Xib (xml version of nib)
    @rblog.info "---------- New session - awaken from nib/xib ----------"
    NSLog 'Awaken from Nib'    # Test
    ## setup_preferences
    # @status_menu.setup_status_menu(self)    # Crashes when menu is used
    setup_status_menu


    # TODO: Auto-empty inbox goes here (when I've figured how to handle a loop with a suitable delay)
    # Or maybe it goes into Video_archive.
  end

  def setup_status_menu   # I've tried to move this to a separate class, but it just crashes, so I'll keep it here.
    @rblog.debug "Enter setup_status_menu"
    statusbar = NSStatusBar.systemStatusBar
    status_item = statusbar.statusItemWithLength(NSVariableStatusItemLength)
    image_name = NSBundle.mainBundle.pathForResource_ofType('stretch', 'tiff')
    image = NSImage.alloc.initWithContentsOfFile(image_name)
    status_item.setImage(image)  # TODO: fix the image
    status_item.setTitle("AH")

    menu = NSMenu.alloc.init
    status_item.setMenu(menu)

    menu_item = menu.addItemWithTitle_action_keyEquivalent( "Empty inbox", "empty_inbox_once:", '')
    menu_item.setTarget(self) # TODO: Will with all probably be moved to another class & module

    menu_item = menu.addItemWithTitle_action_keyEquivalent( "Test", "test:", '')  # TEST
    menu_item.setTarget(self)

    menu_item = menu.addItemWithTitle_action_keyEquivalent( "Watch inbox", "watch_inbox:", '')  # Needs a selected marker, or a change to 'Stop watching inbox'
    menu_item.setTarget(self) # TODO: Will with all probably be moved to another class & module

    #menu_item = menu.addItemWithTitle_action_keyEquivalent( "Preferences...", "set_preferences:", '')
    #menu_item.setTarget(@preferences)

    menu_item = menu.addItemWithTitle_action_keyEquivalent( "Quit", "terminate:", '')
    #menu_item.setKeyEquivalentModifierMask(NSCommandKeyMask)
    menu_item.setTarget(NSApp)

    @rblog.info("Added status menu")
  end
end