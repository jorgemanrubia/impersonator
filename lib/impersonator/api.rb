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

    def impersonate(*arguments, &block)
      if block_given?
        impersonate_object(*arguments, &block)
      else
        object, *methods = arguments
        impersonate_methods(object, *methods)
      end
    end

    private

    def impersonate_object(*methods)
      object_to_impersonate = if current_recording&.record_mode?
                                yield
                              else
                                generate_double(methods)
                              end
      impersonate_methods(object_to_impersonate, *methods)
    end

    def impersonate_methods(object, *methods)
      raise Impersonator::Errors::ConfigurationError, 'You must start a recording to impersonate objects. Use Impersonator.recording {}' unless @current_recording
      ::Impersonator::Proxy.new(object, recording: current_recording, impersonated_methods: methods)
    end

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
