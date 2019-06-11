module Impersonator
  Configuration = Struct.new(:recordings_path, keyword_init: true) do
    DEFAULT_RECORDINGS_PATH = 'spec/recordings'

    def initialize(*)
      super
      self.recordings_path ||= DEFAULT_RECORDINGS_PATH
    end
  end
end
