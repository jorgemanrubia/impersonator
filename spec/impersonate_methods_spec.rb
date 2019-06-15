describe 'Impersonate', clear_recordings: true do
  let(:actual_calculator) { Test::Calculator.new }

  context 'with methods without arguments' do
    it 'records and impersonates a method that return a simple value' do
      test_impersonation do |impersonator|
        expect(impersonator.next).to eq(1)
      end
    end

    it 'records and impersonates multiple invocations in a row of a method that returns a simple value' do
      test_impersonation do |impersonator|
        expect(impersonator.next).to eq(1)
        expect(impersonator.next).to eq(2)
        expect(impersonator.next).to eq(3)
      end
    end

    it 'records and impersonates multiple invocations of multiple methods combined' do
      test_impersonation do |impersonator|
        expect(impersonator.next).to eq(1)
        expect(impersonator.next).to eq(2)
        expect(impersonator.previous).to eq(1)
        expect(impersonator.previous).to eq(0)
        expect(impersonator.next).to eq(1)
      end
    end
  end

  context 'with methods with arguments' do
    it 'records and impersonates invocations of methods with arguments' do
      test_impersonation do |impersonator|
        expect(impersonator.sum(1, 2)).to eq(3)
        expect(impersonator.sum(3, 4)).to eq(7)
      end
    end

    it 'can ignore arguments when matching methods' do
      Impersonator.recording('test recording') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :sum)
        impersonator.configure_method_matching_for(:sum) do |config|
          config.ignore_arguments_at 0
        end

        expect(impersonator.sum(1, 2)).to eq(3)
        expect(actual_calculator).to be_invoked
      end

      actual_calculator.reset

      Impersonator.recording('test recording') do
        impersonator = Impersonator.impersonate_methods(actual_calculator, :sum)

        expect(impersonator.sum(99999999, 2)).to eq(3)
        expect(actual_calculator).not_to be_invoked
      end
    end
  end

  context 'with methods yielding to blocks' do
    it 'replays the yielded values' do
      test_impersonation do |impersonator|
        expect { |block| impersonator.sum(1, 2, &block) }.to yield_with_args(3)
      end
    end

    it 'replays yielding multiple times' do
      test_impersonation do |impersonator|
        expect { |block| impersonator.lineal_sequence(3, &block) }.to yield_successive_args(1, 2, 3)
      end
    end
  end

  describe 'Configuration' do
    it 'can disable replay mode' do
      Impersonator.recording('test recording') do
        build_impersonator.next
        expect(actual_calculator).to be_invoked
      end

      actual_calculator.reset

      Impersonator.recording('test recording', disabled: true) do
        build_impersonator.next
        expect(actual_calculator).to be_invoked
      end
    end
  end

  def test_impersonation(&block)
    Impersonator.recording('test recording') do
      impersonator = build_impersonator

      block.call(impersonator)
      expect(actual_calculator).to be_invoked
    end

    actual_calculator.reset

    Impersonator.recording('test recording') do
      impersonator = build_impersonator
      block.call(impersonator)
      expect(actual_calculator).not_to be_invoked
    end
  end

  def build_impersonator
    Impersonator.impersonate_methods(actual_calculator, :next, :previous, :sum, :lineal_sequence)
  end
end
