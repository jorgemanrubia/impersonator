# frozen_string_literal: true

describe 'Impersonate double', clear_recordings: true do
  let(:actual_calculator) { Test::Calculator.new }

  it "doesn't use the real object in recording mode" do
    Impersonator.recording('test double recording') do
      impersonator = Impersonator.impersonate(:next) { actual_calculator }

      expect(impersonator.next).to eq(1)
      expect(actual_calculator).to be_invoked
    end

    actual_calculator.reset

    Impersonator.recording('test double recording') do
      impersonator = Impersonator.impersonate(:next) { raise 'This should never be invoked' }

      expect(impersonator.next).to eq(1)
      expect(actual_calculator).not_to be_invoked
    end
  end
end
