module Impersonator
  MethodInvocation = Struct.new(:method_instance, :return_value, keyword_init: true)
end
