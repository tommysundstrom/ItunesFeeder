#---
# Excerpted from "RubyCocoa",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/bmrc for more book information.
#---
require 'test/notification-utils'

module PrefsWindowTests
  module NotificationTestSupport
    def inject_watchers_for(name)
      @watcher = flexmock(SomeRandomWatcher.alloc.init)
      @watcher_inbox = NotificationInBox.new(:local,
                                             :observer => @watcher)
      @watcher_inbox.observe(:name => name,
                             :selector => :notification_watcher_selector_that_should_have_been_called)
    end
    alias_method :including_random_watchers_for, :inject_watchers_for

    def inject_announcers
      @outbox = NotificationOutBox.new(:local)
    end
    alias_method :including_random_announcers, :inject_announcers


    def no_more_watchers
      @watcher_inbox.stop_observing if @watcher_inbox
    end

    def watchers_are_notified
      @watcher.should_receive(:notification_watcher_selector_that_should_have_been_called, 0)
    end

    def some_object_announces(*args)
      @outbox.post(*args)
    end
  end
end
