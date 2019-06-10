module Impersonator
  module Dsl
    def recording(label, &block)
      @current_recording = ::Impersonator::Recording.new(label)
      @current_recording.start
      yield
    ensure
      @current_recording.finish
    end

    def current_recording
      @current_recording
    end

    def impersonate(object, *methods)
      ::Impersonator::Proxy.new(object, recording: current_recording, impersonated_methods: methods)
    end
  end
end
