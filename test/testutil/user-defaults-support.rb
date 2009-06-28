#---
# Excerpted from "RubyCocoa",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/bmrc for more book information.
#---
module UserDefaultsHelpers

  def random_prefs(count)
    [ {} ] * count
  end

  def make_fake_defaults_controller(*hashes)
    hashes = hashes.flatten
    archived = archived_translator_prefs(hashes)
    @defaults_controller = {:values => {:translators => archived }}.to_ns
    add_utility_singleton_methods_to_defaults_controller
  end

  def make_mock_defaults_controller(*hashes)
    hashes = hashes.flatten
    archived = archived_translator_prefs(hashes)
    @defaults_controller = rubycocoa_flexmock('defaults controller')
    @defaults_controller.should_receive(:valueForKey, 1).
      and_return({ 'translators' => archived})
    yield(@defaults_controller) if block_given?

    add_utility_singleton_methods_to_defaults_controller
  end

  def new_preferences_facade_mocking(*hashes)
    hashes = hashes.flatten
    make_mock_defaults_controller(hashes)
    connect_pref_facade_to_mocked_defaults
    @pref_facade
  end
  # "make" implies no return value; "new" implies one.
  alias_method :make_mock_preferences_facade, :new_preferences_facade_mocking

  def new_preferences_facade_faking(*hashes)
    hashes = hashes.flatten
    @pref_facade = NameOrientedPreferencesFacade.alloc
    make_fake_defaults_controller(hashes)
    @pref_facade.initWithDefaultsController(@defaults_controller)
    @pref_facade
  end
  # "make" implies no return value; "new" implies one.
  alias_method :make_fake_preferences_facade, :new_preferences_facade_faking



  def connect_pref_facade_to_mocked_defaults
    during { 
      @pref_facade = NameOrientedPreferencesFacade.alloc.initWithDefaultsController(@defaults_controller)
    }.behold! {
      @defaults_controller.should_receive(:addObserver_forKeyPath_options_context, 4).once
    }
  end

  # Stubbing translators.

  def archived_translator_prefs(*hashes)
    hashes = hashes.flatten
    objects = hashes.collect do | hash | 
      translator_pref(hash)
    end
    transformer = DataArrayTransformer.alloc.init
    transformer.reverseTransformedValue(objects)
  end

  def unarchived_translator_prefs(data)
    transformer = DataArrayTransformer.alloc.init
    transformer.transformedValue(data)
  end

  def translator_pref(hash = {})
    retval = TranslatorPreference.alloc.init
    hash.each do | key, value | 
      retval.send(key.to_s+'=', value)
    end
    retval
  end

  # Misc

  def add_utility_singleton_methods_to_defaults_controller
    @defaults_controller.extend(UserDefaultsHelpers)
    def @defaults_controller.translators
      unarchived_translator_prefs(valueForKeyPath('values.translators'))
    end
    def @defaults_controller.find_by_display_name(name)
      translators.find { | p | p.display_name == name }
    end
    def @defaults_controller.favorites
      translators.collect { | p | p.favorite }
    end

    def @defaults_controller.sources
      translators.collect { | p | p.source }
    end
  end
end
