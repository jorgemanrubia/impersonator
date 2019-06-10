module Impersonator
  module Dsl
    def impersonate(object, *methods)
      ::Impersonator::Proxy.new(object, methods)
    end
  end
end
