module Impersonator
  Method = Struct.new(:name, :arguments, :block, :matching_configuration, keyword_init: true) do
    def to_s
      string = name.to_s

      arguments_string = arguments&.collect(&:to_s)&.join(', ')

      string << "(#{arguments_string})"
      string << ' {with block}' if block
      string
    end

    def block_spy
      return nil if !@block_spy && !block

      @block_spy ||= BlockSpy.new(actual_block: block)
    end

    def init_with(coder)
      self.name = coder['name']
      self.arguments = coder['arguments']
      self.matching_configuration = coder['matching_configuration']
      @block_spy = coder['block_spy']
    end

    def encode_with(coder)
      coder['name'] = name
      coder['arguments'] = arguments
      coder['block_spy'] = block_spy
      coder['matching_configuration'] = matching_configuration
    end

    def ==(other_method)
      my_arguments = arguments.dup
      other_arguments = other_method.arguments.dup
      matching_configuration&.ignored_positions&.each do |ignored_position|
        my_arguments.delete_at(ignored_position)
        other_arguments.delete_at(ignored_position)
      end

      name == other_method.name && my_arguments == other_arguments && !block_spy == !other_method.block_spy
    end
  end
end
