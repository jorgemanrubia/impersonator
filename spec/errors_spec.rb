describe 'Error detection', clear_recordings: true do
  let(:actual_calculator) { Test::Calculator.new }
  let(:block) { proc {} }

  it 'does not generate recordings when an error is raised' do
    begin
      Impersonator.recording('error-recording') do
        Impersonator.impersonate_methods(actual_calculator, :add)
        raise 'Some error'
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
        impersonator = Impersonator.impersonate_methods(actual_calculator, :add)
        impersonator.add(1, 2)
      end

      actual_calculator.reset

      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :add)
        expect { impersonator.add(3, 4) }.to raise_error(Impersonator::Errors::MethodInvocationError)
      end
    end

    it 'raises an error when there is an invocation with a not expected a block' do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :add, :lineal_sequence)
        impersonator.add(1, 2, &block)
        impersonator.add(1, 2)
      end

      actual_calculator.reset

      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :add, :lineal_sequence)

        impersonator.add(1, 2, &block)
        expect { impersonator.add(1, 2, &block) }.to raise_error(Impersonator::Errors::MethodInvocationError)
      end
    end

    it 'raises an error when there is an invocation missing a block' do
      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :add, :lineal_sequence)
        impersonator.add(1, 2, &block)
        impersonator.add(1, 2, &block)
      end

      actual_calculator.reset

      Impersonator.recording('simple value') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :add, :lineal_sequence)

        impersonator.add(1, 2, &block)
        expect { impersonator.add(1, 2) }.to raise_error(Impersonator::Errors::MethodInvocationError)
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

describe 'dummy' do
  it 'test me' do
    class Calculator
      def add(number_1, number_2)
        number_1 + number_2
      end
    end

    # The first time it records...
    Impersonator.recording('calculator add') do
      impersonated_calculator = Impersonator.impersonate(:add) { Calculator.new }
      puts impersonated_calculator.add(2, 3) # 5
    end

    # The next time it replays
    Object.send :remove_const, :Calculator # Calculator does not even have to exist now
    Impersonator.recording('calculator add') do
      impersonated_calculator = Impersonator.impersonate(:add) { Calculator.new }
      puts impersonated_calculator.add(2, 3) # 5
    end
  end
end
