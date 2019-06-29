module Impersonator
  # A method invocation groups a {Method method instance} and a return value
  MethodInvocation = Struct.new(:method_instance, :return_value, keyword_init: true)
end
