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
      number_1 + number_2
    end

    private

    def invoked!
      @invoked = true
    end
  end
end
