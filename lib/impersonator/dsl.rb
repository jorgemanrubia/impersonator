module Impersonator
  module Dsl
    def recording(label, &block)
      @current_recording = ::Impersonator::Recording.new(label)
      @current_recording.start
      yield
    ensure
      @current_recording.finish
      @current_recording = nil
    end

    def current_recording
      @current_recording
    end

    def impersonate(object, *methods)
      raise Impersonator::Errors::ConfigurationError, 'You must start a recording to impersonate objects. Use Impersonator.recording {}' unless @current_recording
      ::Impersonator::Proxy.new(object, recording: current_recording, impersonated_methods: methods)
    end
  end
end
