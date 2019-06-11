describe 'Default method return impersonation', clear_recordings: true do
  let(:real_calculator) { Test::Calculator.new }

  context 'with methods without arguments' do
    it 'can record and impersonate a method that return a simple value' do
      test_impersonation do |impersonator|
        expect(impersonator.next).to eq(1)
      end
    end

    it 'can record and impersonate multiple invocations in a row of a method that returns a simple value' do
      test_impersonation do |impersonator|
        expect(impersonator.next).to eq(1)
        expect(impersonator.next).to eq(2)
        expect(impersonator.next).to eq(3)
      end
    end

    it 'can record and impersonate multiple invocations of multiple methods combined' do
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
    it 'can record and impersonate invocations of methods with arguments' do
      test_impersonation do |impersonator|
        expect(impersonator.sum(1, 2)).to eq(3)
        expect(impersonator.sum(3, 4)).to eq(7)
      end
    end
  end

  def test_impersonation(&block)
    Impersonator.recording('simple value') do
      impersonator = build_impersonator

      block.call(impersonator)
      expect(real_calculator).to be_invoked
    end

    real_calculator.reset

    Impersonator.recording('simple value') do
      impersonator = build_impersonator
      block.call(impersonator)
      expect(real_calculator).not_to be_invoked
    end
  end

  def build_impersonator
    Impersonator.impersonate(real_calculator, :next, :previous, :sum)
  end
end