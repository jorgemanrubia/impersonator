module Impersonator
  # A simple double implementation. It will generate empty stubs for the passed list of methods
  class Double
    # @param [Array<String, Symbol>] methods The list of methods this double will respond to
    def initialize(*methods)
      define_methods(methods)
    end

    private

    def define_methods(methods)
      methods.each do |method|
        self.class.define_method(method) {}
      end
    end
  end
end
