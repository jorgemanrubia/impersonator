module Impersonator
  BlockInvocation = Struct.new(:arguments, :dispatched, keyword_init: true)
end
