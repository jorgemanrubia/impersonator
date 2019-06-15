describe Impersonator::Double do
  describe '#initialize' do
    it 'generates methods for the list of names passed in' do
      object = described_class.new(:sum, :next)
      object.sum
      object.next
    end
  end
end
