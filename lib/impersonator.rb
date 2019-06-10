require 'impersonator/version'

require 'zeitwerk'
require 'logger'
loader = Zeitwerk::Loader.for_gem
loader.setup

module Impersonator
  extend Dsl

  def self.logger
    @logger ||= ::Logger.new(STDOUT).tap do |logger|
      logger.level = Logger::WARN
    end
  end
end
