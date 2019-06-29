module Impersonator
  # General configuration settings for Impersonator
  Configuration = Struct.new(:recordings_path, keyword_init: true) do
    # @!attribute recordings_path [String] The path where recordings are saved to

    DEFAULT_RECORDINGS_FOLDER = 'recordings'.freeze

    def initialize(*)
      super
      self.recordings_path ||= detect_default_recordings_path
    end

    private

    def detect_default_recordings_path
      base_path = File.exist?('spec') ? 'spec' : 'test'
      File.join(base_path, DEFAULT_RECORDINGS_FOLDER)
    end
  end
end
