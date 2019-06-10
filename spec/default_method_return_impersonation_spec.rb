describe 'Default method return impersonation', clear_recordings: true do
  let(:real_object) { DummyCounter.new }

  context 'with methods that return a simple value' do
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

  pending 'raises an error when trying to impersonate without starting a recording'
  pending 'raises an error when the method to impersonate does not exist'

  class DummyCounter
    def initialize
      @counter = 0
    end

    def invoked?
      @invoked
    end

    def reset
      @invoked = false
    end

    def next
      @invoked = true
      @counter += 1
    end

    def previous
      @invoked = true
      @counter -= 1
    end
  end

  def test_impersonation(&block)
    Impersonator.recording('simple value') do
      impersonator = Impersonator.impersonate(real_object, :next, :previous)

      block.call(impersonator)
      expect(real_object).to be_invoked
    end

    real_object.reset

    Impersonator.recording('simple value') do
      impersonator = Impersonator.impersonate(real_object, :next, :previous)
      block.call(impersonator)
      expect(real_object).not_to be_invoked
    end
  end
end
