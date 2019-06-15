module Impersonator
  Configuration = Struct.new(:recordings_path, keyword_init: true) do
    DEFAULT_RECORDINGS_FOLDER = 'recordings'

    def initialize(*)
      super
      self.recordings_path ||= detect_default_recordings_path
    end

    private

    def detect_default_recordings_path
      base_path = File.exists?('spec') ? 'spec' : 'test'
      File.join(base_path, DEFAULT_RECORDINGS_FOLDER)
    end
  end
end
