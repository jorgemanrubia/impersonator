RSpec.configure do |config|
  config.around(:example, clear_recordings: true) do |example|
    clear_recordings_dir
    example.run
  end
end
