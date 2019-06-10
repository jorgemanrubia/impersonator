require "impersonator/version"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Impersonator
  extend Dsl
end
