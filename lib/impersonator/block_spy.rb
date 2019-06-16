module Impersonator
  BlockSpy = Struct.new(:block_invocations, :actual_block, keyword_init: true) do
    def block
      @block ||= proc do |*arguments|
        self.block_invocations ||= []
        self.block_invocations << BlockInvocation.new(arguments: arguments)
        return_value = actual_block.call(*arguments)
        return_value
      end
    end

    def init_with(coder)
      self.block_invocations = coder['block_invocations']
    end

    def encode_with(coder)
      coder['block_invocations'] = block_invocations
    end
  end
end
