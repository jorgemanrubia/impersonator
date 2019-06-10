describe 'Default method return impersonation', clear_recordings: true do
  let(:real_object) { DummyClass.new }

  it 'can record and impersonate a method that return a simple value' do
    Impersonator.recording('simple value') do
      impersonator = Impersonator.impersonate(real_object, :foo)
      expect(impersonator.foo).to eq(:bar)
      expect(real_object).to be_invoked
    end

    real_object.reset

    Impersonator.recording('simple value') do
      impersonator = Impersonator.impersonate(real_object, :foo)
      expect(impersonator.foo).to eq(:bar)
      expect(real_object).not_to be_invoked
    end
  end

  pending 'raises an error when trying to impersonate without starting a recording'
  pending 'raises an error when the method to impersonate does not exist'

  class DummyClass
    def invoked?
      @invoked
    end

    def reset
      @invoked = false
    end

    def foo
      @invoked = true
      :bar
    end
  end
end
