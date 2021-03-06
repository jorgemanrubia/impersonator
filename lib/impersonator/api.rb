module Impersonator
  # Public API exposed by the global `Impersonator` module.
  module Api
    # Wraps the execution of the yielded code withing a new {Recording recording} titled with the
    # passed label.
    #
    # @param [String] label The label for the recording
    # @param [Boolean] disabled `true` will disable replay mode and always execute code in *record*
    #   mode. `false` by default
    def recording(label, disabled: false)
      @current_recording = ::Impersonator::Recording.new label,
                                                         disabled: disabled,
                                                         recordings_path: configuration.recordings_path
      @current_recording.start
      yield
      @current_recording.finish
    ensure
      @current_recording = nil
    end

    # The current recording, if any, or `nil` otherwise.
    #
    # @return [Recording, nil]
    def current_recording
      @current_recording
    end

    # Configures how Impersonator works by yielding a {Configuration configuration} object
    # you can use to tweak settings.
    #
    # ```
    # Impersonator.configure do |config|
    #   config.recordings_path = 'my/own/recording/path'
    # end
    # ```
    #
    # @yieldparam config [Configuration]
    def configure
      yield configuration
    end

    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Reset configuration and other global state.
    #
    # It is meant to be used internally by tests.
    def reset
      @current_recording = nil
      @configuration = nil
    end

    # Receives a list of methods to impersonate and a block that will be used, at record time, to
    # instantiate the object to impersonate. At replay time, it will generate a double that will
    # replay the methods.
    #
    #   impersonator = Impersonator.impersonate(:add, :subtract) { Calculator.new }
    #   impersonator.add(3, 4)
    #
    # Notice that the actual object won't be instantiated in record mode. For that reason, the
    # impersonated object will only respond to the list of impersonated methods.
    #
    # If you need to invoke other (not impersonated) methods see #impersonate_method instead.
    #
    # @param [Array<Symbols, Strings>] methods list of methods to impersonate
    # @return [Proxy] the impersonated proxy object
    def impersonate(*methods)
      unless block_given?
        raise ArgumentError, 'Provide a block to instantiate the object to impersonate in record mode'
      end

      object_to_impersonate = if current_recording&.record_mode?
                                yield
                              else
                                Double.new(*methods)
                              end
      impersonate_methods(object_to_impersonate, *methods)
    end

    # Impersonates a list of methods of a given object
    #
    # The returned object will impersonate the list of methods and will delegate the rest of method
    # calls to the actual object.
    #
    # @param [Object] actual_object The actual object to impersonate
    # @param [Array<Symbols, Strings>] methods list of methods to impersonate
    # @return [Proxy] the impersonated proxy object
    def impersonate_methods(actual_object, *methods)
      unless @current_recording
        raise Impersonator::Errors::ConfigurationError, 'You must start a recording to impersonate'\
              ' objects. Use Impersonator.recording {}'
      end

      ::Impersonator::Proxy.new(actual_object, recording: current_recording,
                                               impersonated_methods: methods)
    end
  end
end
