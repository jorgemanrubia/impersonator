describe 'Error detection', clear_recordings: true do
  let(:real_calculator) { Test::Calculator.new }

  describe Impersonator::Errors::ConfigurationError do
    it 'raises an error when trying to impersonate without starting a recording' do
      expect { Impersonator.impersonate(real_calculator, :next, :previous) }.to raise_error(Impersonator::Errors::ConfigurationError)
    end

    it 'raises an error when the method to impersonate does not exist' do
      Impersonator.recording('missing method') do
        expect { Impersonator.impersonate(real_calculator, :some_missing_method) }.to raise_error(Impersonator::Errors::ConfigurationError)
      end
    end
  end

  describe Impersonator::Errors::MethodInvocationError do
    it 'raises an error when there is an invocation that is not recorded' do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate(real_calculator, :next, :previous)
        impersonator.next
      end

      real_calculator.reset

      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate(real_calculator, :next, :previous)

        impersonator.next
        expect { impersonator.next }.to raise_error(Impersonator::Errors::MethodInvocationError)
      end
    end
  end


  it 'raises an error when there more recorded invocations that actual invocations' do
    Impersonator.recording('simple value') do
      impersonator = Impersonator.impersonate(real_calculator, :next, :previous)
      impersonator.next
      impersonator.next
    end

    real_calculator.reset

    expect do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate(real_calculator, :next, :previous)

        impersonator.next
      end
    end.to raise_error(Impersonator::Errors::MethodInvocationError)
  end
end
