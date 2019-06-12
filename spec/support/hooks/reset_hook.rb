RSpec.configure do |config|
  config.before(:example) do
    Impersonator.reset
  end
end
