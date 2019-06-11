module Test
  module FileHelpers
    def clear_recordings_dir
      FileUtils.rm_rf(Dir.glob('spec/recordings/*'))
    end
  end
end
