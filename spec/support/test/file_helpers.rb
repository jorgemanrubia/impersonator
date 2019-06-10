module Test
  module FileHelpers
    def clear_fixtures_dir
      FileUtils.rm_rf(Dir.glob('spec/recordings/*'))
    end
  end
end
