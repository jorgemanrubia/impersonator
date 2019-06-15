module Impersonator
  class Double
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
