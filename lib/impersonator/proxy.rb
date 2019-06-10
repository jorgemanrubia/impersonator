module Impersonator
  class Proxy
    attr_reader :impersonated_object, :impersonated_methods

    def initialize(impersonated_object, *impersonated_methods)
      @impersonated_object = impersonated_object
      @impersonated_methods = impersonated_methods
    end

    def method_missing(method_name, *args, &block)
      impersonated_object.send(method_name, *args, &block)
    end

    def respond_to_missing?(method_name, *args)
      impersonated_object.respond_to_missing?(method_name, *args)
    end
  end
end


