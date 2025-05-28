require 'rails_helper'

RSpec.describe CaseStudy, type: :model do
  describe '#tx_resources' do
    let!(:case_study_1) { create(:case_study, title: 'one', position: 2) }
    let!(:case_study_2) { create(:case_study, title: 'two', position: 1) }

    it 'returns case studies in id order' do
      expect(CaseStudy.tx_resources).to match_array([case_study_1, case_study_2])
    end
  end

  describe '.without_images' do
    context 'when all case studies have images attached' do
      let!(:case_study_with_image_1) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/placeholder.png')) }
      let!(:case_study_with_image_2) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/placeholder.png')) }

      it 'returns nothing' do
        expect(CaseStudy.without_images).to be_empty
      end
    end

    context 'when some case studies do not have images attached' do
      let!(:case_study_with_image) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/placeholder.png')) }
      let!(:case_study_without_image) { create(:case_study) }

      it 'returns only case studies without images' do
        expect(CaseStudy.without_images).to match_array([case_study_without_image])
      end
    end

    context 'when no case studies have images attached' do
      let!(:case_study_without_image_1) { create(:case_study) }
      let!(:case_study_without_image_2) { create(:case_study) }

      it 'returns all case studies' do
        expect(CaseStudy.without_images).to match_array([case_study_without_image_1, case_study_without_image_2])
      end
    end

    context 'when there are no case studies' do
      it 'returns an empty ActiveRecord::Relation' do
        expect(CaseStudy.without_images).to be_empty
      end
    end
  end

  describe '#organisation_type_name' do
    let(:case_study) { build(:case_study, organisation: organisation) }

    context 'when organisation is a School' do
      let(:organisation) { build(:school, school_type: 'primary') }

      it 'returns the translated school type' do
        expect(case_study.organisation_type_name).to eq('Primary')
      end
    end

    context 'when organisation is a SchoolGroup' do
      let(:organisation) { build(:school_group, group_type: 'multi_academy_trust') }

      it 'returns the translated group type' do
        expect(case_study.organisation_type_name).to eq('Multi-Academy Trust')
      end
    end

    context 'when organisation is neither a School nor a SchoolGroup' do
      let(:organisation) { }

      it 'returns the default school label' do
        expect(case_study.organisation_type_name).to eq('School')
      end
    end
  end
end
