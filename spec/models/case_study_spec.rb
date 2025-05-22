require 'rails_helper'

RSpec.describe CaseStudy, type: :model do
  describe '#tx_resources' do
    let!(:case_study_1) { create(:case_study, title: 'one', position: 2) }
    let!(:case_study_2) { create(:case_study, title: 'two', position: 1) }

    it 'returns case studies in id order' do
      expect(CaseStudy.tx_resources).to match_array([case_study_1, case_study_2])
    end
  end

  describe '.all_with_image?' do
    context 'when all case studies have images attached' do
      let!(:case_study_with_image_1) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/placeholder.png')) }
      let!(:case_study_with_image_2) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/placeholder.png')) }

      it 'returns true' do
        expect(CaseStudy.all_with_image?).to be true
      end
    end

    context 'when not all case studies have images attached' do
      let!(:case_study_with_image) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/placeholder.png')) }
      let!(:case_study_without_image) { create(:case_study) }

      it 'returns false' do
        expect(CaseStudy.all_with_image?).to be false
      end
    end

    context 'when there are no case studies' do
      it 'returns true' do
        expect(CaseStudy.all_with_image?).to be true
      end
    end
  end
end
