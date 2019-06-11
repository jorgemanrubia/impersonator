module Impersonator
  BlockSpy = Struct.new(:arguments, :return_value, :actual_block, keyword_init: true) do
    def block
      @block ||= proc do |*arguments|
        self.arguments = arguments
        return_value = actual_block.call(*arguments)
        return_value
      end
    end

    def init_with(coder)
      self.arguments = coder['arguments']
      self.return_value = coder['return_value']
    end

    def encode_with coder
      coder['arguments'] = arguments
      coder['return_value'] = return_value
    end
  end
end
