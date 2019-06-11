describe 'Error detection', clear_recordings: true do
  let(:real_calculator) { Test::Calculator.new }

  it 'raises an error when trying to impersonate without starting a recording' do
    expect { Impersonator.impersonate(real_calculator, :next, :previous) }.to raise_error(Impersonator::Errors::ConfigurationError)
  end

  it 'raises an error when the method to impersonate does not exist' do
    Impersonator.recording('missing method') do
      expect{ Impersonator.impersonate(real_calculator, :some_missing_method) }.to raise_error(Impersonator::Errors::ConfigurationError)
    end
  end

  pending 'raises an error when there is an invocation that is not recorded'

  pending 'raises an error when there more recorded invocations that actual invocations'

  def test_impersonation(&block)
    Impersonator.recording('simple value') do
      impersonator = Impersonator.impersonate(real_calculator, :next, :previous)

      block.call(impersonator)
      expect(real_calculator).to be_invoked
    end

    real_calculator.reset

    Impersonator.recording('simple value') do
      impersonator = Impersonator.impersonate(real_calculator, :next, :previous)
      block.call(impersonator)
      expect(real_calculator).not_to be_invoked
    end
  end
end
