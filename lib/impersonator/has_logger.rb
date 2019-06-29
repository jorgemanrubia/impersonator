module Impersonator
  # A mixin that will add a method `logger` to access a logger instance
  #
  # @see ::Impersonator.logger
  module HasLogger
    def logger
      ::Impersonator.logger
    end
  end
end
