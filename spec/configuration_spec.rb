describe 'Error detection', clear_recordings: true do
  let(:real_calculator) { Test::Calculator.new }

  describe '#recordings_path' do
    it 'defaults to spec/recordings' do
      validate_generates_fixture('spec/recordings/test recording.yml')
    end

    it 'can change the place where recordings are generated' do
      validate_generates_fixture('spec/recordings/myfolder/test recording.yml') do
        Impersonator.configure do |config|
          config.recordings_path = 'spec/recordings/myfolder'
        end
      end
    end
  end

  def validate_generates_fixture(expected_file_path)
    expect(File.exist?(expected_file_path)).to be_falsey
    yield if block_given?

    Impersonator.recording('test recording') do
      impersonator = Impersonator.impersonate(real_calculator, :next)
      impersonator.next
      expect(real_calculator).to be_invoked
    end

    expect(File.exist?(expected_file_path)).to be_truthy
  end
end
