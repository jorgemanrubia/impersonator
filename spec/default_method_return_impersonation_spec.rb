describe 'Default method return impersonation ' do
  let(:real_object) { DummyClass.new }

  it 'can record and impersonate a method that return a simple value' do
    impersonator = Impersonator.impersonate(real_object, :foo)
    expect(impersonator.foo).to eq(:bar)
    expect(real_object).to be_invoked

    impersonator = Impersonator.impersonate(real_object, :foo)
    expect(impersonator.foo).to eq(:bar)
    expect(real_object).not_to be_invoked
  end

  class DummyClass
    def invoked?
      @invoked
    end

    def foo
      @invoked = true
      :bar
    end
  end
end
