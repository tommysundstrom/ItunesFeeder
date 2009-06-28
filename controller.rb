require 'osx/cocoa'
require 'log'





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
    setup_preferences
    ## @status_menu.setup_status_menu(self)    # Crashes when menu is used
    setup_status_menu


    # TODO: Auto-empty inbox goes here (when I've figured how to handle a loop with a suitable delay)
    # Or maybe it goes into Video_archive.
  end

  def setup_preferences
    require 'controller_preferences'
    @preferences = Preferences.new
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

  def empty_inbox_once(sender)
    @rblog.debug "Started by #{sender} choosing empty_inbox_once"

    video_archive = Video_archive.new(@preferences)   # BUG NŒgonstas i den hŠr hŠnder nŒgot som dšdar menyn. Men mŠrkligt nog dšr den
          # inte innan den hŠr funktionen avslutas. Tycks ocksŒ som att det lšste sig nŠr jag kommenterade bort alla @classlog. MŠrkligt...
          # NŠ fan, det blev Šnnu mŠrkligare. Nu fšrsvinner den INTE lŠngre fšrsta gŒngen man ALLTID ANDRA som jag tar menyvalet.
    video_archive.empty_inbox
    @rblog.debug "Exits 'empty_inbox_once'"
  end

  def test(sender)
    @rblog.debug "Enters and exits test"
  end

  def watch_inbox(sender)
    Log.info "Watching inbox"
    @rblog.debug "Started by #{sender}"
    video_archive = Video_archive.new(@preferences)
    while true do
      @rblog.debug "Checking the inbox"
      video_archive.empty_inbox
      sleep 5 #60*10 # 10 minutes
    end
  end
end