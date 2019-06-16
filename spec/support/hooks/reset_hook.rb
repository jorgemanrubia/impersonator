RSpec.configure do |config|
  config.before do
    Impersonator.reset
  end
end
