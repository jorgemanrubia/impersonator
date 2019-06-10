module Impersonator
  class Proxy
    attr_reader :impersonated_object

    def initialize(impersonated_object, recording:, impersonated_methods:)
      @impersonated_object = impersonated_object
      @impersonated_methods = impersonated_methods.collect(&:to_sym)
      @recording = recording
    end

    def method_missing(method_name, *args, &block)
      if @impersonated_methods.include?(method_name.to_sym)
        invoke_impersonated_method(method_name, *args, &block)
      else
        @impersonated_object.send(method_name, *args, &block)
      end
    end

    def respond_to_missing?(method_name, *args)
      impersonated_object.respond_to_missing?(method_name, *args)
    end

    private

    attr_reader :recording, :impersonated_methods

    def logger
      ::Impersonator.logger
    end

    def invoke_impersonated_method(method_name, *args, &block)
      method = Method.new(name: method_name, arguments: args, block: block)
      if recording.replay_mode?
        recording.replay(method)
      else
        @impersonated_object.send(method_name, *args, &block).tap do |return_value|
          recording.record(method, return_value)
        end
      end
    end
  end
end


