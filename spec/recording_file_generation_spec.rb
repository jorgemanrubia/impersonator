describe 'Recording file generation', clear_recordings: true do
  let(:actual_calculator) { Test::Calculator.new }

  it 'generates a fixture file named after the recording label by replacing spaces with -' do
    validate_fixture_was_generated for_label: 'my example', expected_file_name: 'my-example.yml'
  end

  it 'eliminates symbols from label when generating file names' do
    validate_fixture_was_generated for_label: '((my()#(example::))',
                                   expected_file_name: 'my-example.yml'
  end

  def validate_fixture_was_generated(for_label:, expected_file_name:)
    expected_file_path = "spec/recordings/#{expected_file_name}"

    expect(File.exist?(expected_file_path)).to be_falsey
    yield if block_given?

    Impersonator.recording(for_label) do
      impersonator = Impersonator.impersonate_methods(actual_calculator, :next)
      impersonator.next
      expect(actual_calculator).to be_invoked
    end

    expect(File.exist?(expected_file_path)).to be_truthy
  end
end
