module Impersonator
  Method = Struct.new(:name, :arguments, :block, keyword_init: true) do
    def to_s
      string = "#{name}"

      arguments_string = arguments&.collect(&:to_s)&.join(', ')

      string << "(#{arguments_string})"
      string << " {with block}" if block
      string
    end

    def block_spy
      return nil if !@block_spy && !block
      @block_spy ||= BlockSpy.new(actual_block: block)
    end

    def init_with(coder)
      self.name = coder['name']
      self.arguments = coder['arguments']
      @block_spy = coder['block_spy']
    end

    def encode_with coder
      coder['name'] = name
      coder['arguments'] = arguments
      coder['block_spy'] = block_spy
    end

    def ==(other_method)
      self.name == other_method.name && self.arguments == other_method.arguments && !!block_spy == !!other_method.block_spy
    end
  end
end
