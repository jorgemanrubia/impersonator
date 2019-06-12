# frozen_string_literal: true

describe 'Impersonate double', clear_recordings: true do
  let(:real_calculator) { Test::Calculator.new }

  it "doesn't use the real object in recording mode" do
    Impersonator.recording('test double recording') do
      impersonator = Impersonator.impersonate_double(:next) { real_calculator }

      expect(impersonator.next).to eq(1)
      expect(real_calculator).to be_invoked
    end

    real_calculator.reset

    Impersonator.recording('test double recording') do
      impersonator = Impersonator.impersonate_double(:next) { raise 'This should never be invoked' }

      expect(impersonator.next).to eq(1)
      expect(real_calculator).not_to be_invoked
    end
  end
end
