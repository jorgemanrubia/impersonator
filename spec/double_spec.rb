describe Impersonator::Double do
  describe '#initialize' do
    it 'generates methods for the list of names passed in' do
      object = described_class.new(:add, :next)
      object.add
      object.next
    end
  end
end
