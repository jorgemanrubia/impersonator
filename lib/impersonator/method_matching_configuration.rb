module Impersonator
  class MethodMatchingConfiguration
    attr_reader :ignored_positions

    def initialize
      @ignored_positions = []
    end

    def ignore_arguments_at(*positions)
      ignored_positions.push(*positions)
    end
  end
end
