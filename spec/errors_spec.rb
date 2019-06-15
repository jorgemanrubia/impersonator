describe 'Error detection', clear_recordings: true do
  let(:actual_calculator) { Test::Calculator.new }
  let(:block) { proc {} }

  it 'does not generate recordings when an error is raised' do
    begin
      Impersonator.recording('error-recording') do
        Impersonator.impersonate_methods(actual_calculator, :sum)
        raise "Some error"
      end
    rescue StandardError
    end

    expect(File.exist?('spec/recordings/error-recording.yml')).to be_falsey
  end

  describe Impersonator::Errors::ConfigurationError do
    it 'raises an error when trying to impersonate without starting a recording' do
      expect { Impersonator.impersonate_methods(actual_calculator, :next, :previous) }.to raise_error(Impersonator::Errors::ConfigurationError)
    end

    it 'raises an error when the method to impersonate does not exist' do
      Impersonator.recording('missing method') do
        expect { Impersonator.impersonate_methods(actual_calculator, :some_missing_method) }.to raise_error(Impersonator::Errors::ConfigurationError)
      end
    end
  end

  describe Impersonator::Errors::MethodInvocationError do
    it 'raises an error when there is an invocation that is not recorded' do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :next, :previous)
        impersonator.next
      end

      actual_calculator.reset

      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :next, :previous)

        impersonator.next
        expect { impersonator.next }.to raise_error(Impersonator::Errors::MethodInvocationError)
      end
    end

    it 'raises an error when invoking method with the wrong arguments in replay mode' do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :sum)
        impersonator.sum(1, 2)
      end

      actual_calculator.reset

      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :sum)
        expect { impersonator.sum(3, 4) }.to raise_error(Impersonator::Errors::MethodInvocationError)
      end
    end

    it 'raises an error when there is an invocation with a not expected a block' do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :sum, :lineal_sequence)
        impersonator.sum(1, 2, &block)
        impersonator.sum(1, 2)
      end

      actual_calculator.reset

      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :sum, :lineal_sequence)

        impersonator.sum(1, 2, &block)
        expect { impersonator.sum(1, 2, &block) }.to raise_error(Impersonator::Errors::MethodInvocationError)
      end
    end

    it 'raises an error when there is an invocation missing a block' do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :sum, :lineal_sequence)
        impersonator.sum(1, 2, &block)
        impersonator.sum(1, 2, &block)
      end

      actual_calculator.reset

      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :sum, :lineal_sequence)

        impersonator.sum(1, 2, &block)
        expect { impersonator.sum(1, 2) }.to raise_error(Impersonator::Errors::MethodInvocationError)
      end
    end
  end

  it 'raises an error when there more recorded invocations that actual invocations' do
    Impersonator.recording('simple value') do
      impersonator = Impersonator.impersonate_methods(actual_calculator, :next, :previous)
      impersonator.next
      impersonator.next
    end

    actual_calculator.reset

    expect do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :next, :previous)

        impersonator.next
      end
    end.to raise_error(Impersonator::Errors::MethodInvocationError)
  end
end
