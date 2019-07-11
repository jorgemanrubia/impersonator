module Impersonator
  # A proxy represents the impersonated object at both record and replay times.
  #
  # For not impersonated methods, it will just delegate to the impersonate object. For impersonated
  # methods, it will interact with the {Recording recording} for recording or replaying the object
  # interactions.
  class Proxy
    include HasLogger

    attr_reader :impersonated_object

    # @param [Object] impersonated_object
    # @param [Recording] recording
    # @param [Array<Symbol, String>] impersonated_methods The methods to impersonate
    def initialize(impersonated_object, recording:, impersonated_methods:)
      validate_object_has_methods_to_impersonate!(impersonated_object, impersonated_methods)

      @impersonated_object = impersonated_object
      @impersonated_methods = impersonated_methods.collect(&:to_sym)
      @recording = recording
      @method_matching_configurations_by_method = {}
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

    # Configure matching options for a given method
    #
    # ```ruby
    # impersonator.configure_method_matching_for(:add) do |config|
    #   config.ignore_arguments_at 0
    # end
    # ```
    #
    # @param [String, Symbol] method The method to configure matching options for
    # @yieldparam config [MethodMatchingConfiguration]
    def configure_method_matching_for(method)
      method_matching_configurations_by_method[method.to_sym] ||= MethodMatchingConfiguration.new
      yield method_matching_configurations_by_method[method]
    end

    private

    attr_reader :recording, :impersonated_methods, :method_matching_configurations_by_method

    def validate_object_has_methods_to_impersonate!(object, methods_to_impersonate)
      missing_methods = methods_to_impersonate.find_all do |method|
        !object.respond_to?(method.to_sym)
      end

      unless missing_methods.empty?
        raise Impersonator::Errors::ConfigurationError, 'These methods to impersonate does not'\
                      "exist: #{missing_methods.inspect}"
      end
    end

    def invoke_impersonated_method(method_name, *args, &block)
      matching_configuration = method_matching_configurations_by_method[method_name.to_sym]
      method = Method.new(name: method_name, arguments: args, block: block,
                          matching_configuration: matching_configuration)
      recording.invoke(@impersonated_object, method, args)
    end
  end
end
