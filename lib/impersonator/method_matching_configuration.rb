module Impersonator
  # Configuration options for matching methods
  class MethodMatchingConfiguration
    attr_reader :ignored_positions

    def initialize
      @ignored_positions = []
    end

    # Configure positions to ignore
    #
    # @param [Array<Integer>] positions The positions of arguments to ignore (0 being the first one)
    def ignore_arguments_at(*positions)
      ignored_positions.push(*positions)
    end
  end
end
