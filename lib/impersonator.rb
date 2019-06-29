require 'impersonator/version'

require 'zeitwerk'
require 'logger'
require 'fileutils'
require 'yaml'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Impersonator
  extend Api

  # The gem logger instance
  #
  # @return [::Logger]
  def self.logger
    @logger ||= ::Logger.new(STDOUT).tap do |logger|
      logger.level = Logger::WARN
      logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    end
  end
end
