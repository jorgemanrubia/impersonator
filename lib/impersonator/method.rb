module Impersonator
  Method = Struct.new(:name, :arguments, :block, keyword_init: true) do
    def to_s
      string = "#{name}"

      arguments_string = arguments.collect(&:to_s).join(', ')

      string << "(#{arguments_string})"
      string
    end
  end
end
