module Impersonator
  class Proxy
    include HasLogger

    attr_reader :impersonated_object

    def initialize(impersonated_object, recording:, impersonated_methods:)
      validate_object_has_methods_to_impersonate!(impersonated_object, impersonated_methods)

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

    def validate_object_has_methods_to_impersonate!(object, methods_to_impersonate)
      existing_methods = object.methods

      missing_methods = methods_to_impersonate.find_all do |method|
        !existing_methods.include?(method.to_sym)
      end

      raise Impersonator::Errors::ConfigurationError, "These methods to impersonate does not exist: #{missing_methods.inspect}" unless missing_methods.empty?
    end

    def invoke_impersonated_method(method_name, *args, &block)
      method = Method.new(name: method_name, arguments: args, block: block)
      if recording.replay_mode?
        recording.replay(method)
      else
        @impersonated_object.send(method_name, *args, &method.block_spy.block).tap do |return_value|
          recording.record(method, return_value)
        end
      end
    end
  end
end


