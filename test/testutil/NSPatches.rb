#---
# Excerpted from "RubyCocoa",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/bmrc for more book information.
#---
# Various patches that make tests arguably more readable. 
# Some of these are probably bad ideas.

module OSX
  class NSButton
    def displayed_text
      state == NSOffState ? title : alternateTitle
    end
  end

  class NSTextView
    def displayed_text
      textStorage.to_ruby
    end
  end

  class NSComboBox
    # To simulate user picking, we have to adjust both parts of the combo box.
    def pick_index(index)
      selectItemAtIndex(index)
      self.stringValue = self[index]
    end

    def [](index)
      dataSource.objc_send(:comboBox, self,
                           :objectValueForItemAtIndex, index)
    end
  end
end

