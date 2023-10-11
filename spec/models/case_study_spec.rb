require 'rails_helper'

RSpec.describe CaseStudy, type: :model do
  let!(:case_study_1) { create(:case_study, title: 'one', position: 0) }
  let!(:case_study_2) { create(:case_study, title: 'two', position: 1) }

  it '#tx_resources' do
    expect(CaseStudy.tx_resources).to match_array([case_study_1, case_study_2])
  end
end
