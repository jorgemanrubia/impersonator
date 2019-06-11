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
      @invoked = true
      @counter += 1
    end

    def previous
      @invoked = true
      @counter -= 1
    end
  end
end
