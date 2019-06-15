module Impersonator
  module Api
    def recording(label, disabled: false, &block)
      @current_recording = ::Impersonator::Recording.new(label, disabled: disabled, recordings_path: configuration.recordings_path)
      @current_recording.start
      yield
    ensure
      @current_recording.finish
      @current_recording = nil
    end

    def current_recording
      @current_recording
    end

    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    # Reset configuration and other global state
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
    # Notice that the actual object won't be instantiated in record mode. For that reason, the impersonated
    # object will only respond to the list of impersonated methods.
    #
    # If you need to invoke other (not impersonated) methods see #impersonate_method instead.
    #
    # @return [Object] the impersonated object
    def impersonate(*methods)
      raise ArgumentError, 'Provide a block to instantiate the object to impersonate in record mode' unless block_given?
      object_to_impersonate = if current_recording&.record_mode?
                                yield
                              else
                                generate_double(methods)
                              end
      impersonate_methods(object_to_impersonate, *methods)
    end

    # Impersonates a list of methods of a given object
    #
    # The returned object will impersonate the list of methods and will delegate the rest of method calls
    # to the actual object.
    #
    # @return [Object] the impersonated object
    def impersonate_methods(actual_object, *methods)
      raise Impersonator::Errors::ConfigurationError, 'You must start a recording to impersonate objects. Use Impersonator.recording {}' unless @current_recording
      ::Impersonator::Proxy.new(actual_object, recording: current_recording, impersonated_methods: methods)
    end

    private

    def generate_double(methods)
      double_class = Class.new do
        methods.each do |method|
          define_method(method) {}
        end
      end

      double_class.new
    end
  end
end
