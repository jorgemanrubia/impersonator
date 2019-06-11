module Test
  # Dummy class to test method invocations
  class Calculator
    def initialize
      @counter = 0
    end

    def invoked?
      @invoked
    end

    def reset
      @invoked = false
    end

    def next
      invoked!
      @counter += 1
    end

    def previous
      invoked!
      @counter -= 1
    end

    def sum(number_1, number_2)
      invoked!
      result = number_1 + number_2
      if block_given?
        yield result
      else
        result
      end
    end

    private

    def invoked!
      @invoked = true
    end
  end
end
