module Impersonator
  MethodInvocation = Struct.new(:method, :return_value, keyword_init: true)
end
