require 'rails_helper'

RSpec.describe CaseStudy, type: :model do
  describe '#tx_resources' do
    let!(:case_study_1) { create(:case_study, title: 'one', position: 2) }
    let!(:case_study_2) { create(:case_study, title: 'two', position: 1) }

    it 'returns case studies in id order' do
      expect(CaseStudy.tx_resources).to match_array([case_study_1, case_study_2])
    end

    context 'when there is an unpublished case study' do
      let!(:unpublished) { create(:case_study, title: 'two', position: 3, published: false) }

      it 'does not include unpublished case studies' do
        expect(CaseStudy.tx_resources).not_to include(unpublished)
      end
    end
  end

  describe '.without_images' do
    context 'when all case studies have images attached' do
      let!(:case_study_with_image_1) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/laptop.jpg')) }
      let!(:case_study_with_image_2) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/laptop.jpg')) }

      it 'returns nothing' do
        expect(CaseStudy.without_images).to be_empty
      end
    end

    context 'when some case studies do not have images attached' do
      let!(:case_study_with_image) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/laptop.jpg')) }
      let!(:case_study_without_image) { build(:case_study, image: nil).tap { |cs| cs.save(validate: false) } }

      it 'returns only case studies without images' do
        expect(CaseStudy.without_images).to match_array([case_study_without_image])
      end
    end

    context 'when no case studies have images attached' do
      let!(:case_study_without_image_1) { build(:case_study, image: nil).tap { |cs| cs.save(validate: false) } }
      let!(:case_study_without_image_2) { build(:case_study, image: nil).tap { |cs| cs.save(validate: false) } }

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

  describe '#tag_list' do
    context 'when there are no tags' do
      let!(:case_study) { create(:case_study, tags: nil) }

      it 'returns an empty array' do
        expect(case_study.tag_list).to eq([])
      end
    end

    context 'when there are tags' do
      let!(:case_study) { create(:case_study, tags: 'one, two, three') }

      it 'returns a list of tags' do
        expect(case_study.tag_list).to match_array(['one', 'two', 'three'])
      end
    end
  end

  describe '#tags_{locale}=' do
    let!(:case_study) { create(:case_study, tags_en: 'one, two, three', tags_cy: 'un, dau, tri') }

    context 'when english and welsh tags are set' do
      it 'stores the english tags' do
        expect(case_study.tags_en).to eq('one, two, three')
      end

      it 'stores the welsh tags' do
        expect(case_study.tags_cy).to eq('un, dau, tri')
      end
    end

    context 'when there are extra spaces in the tags' do
      let!(:case_study) { create(:case_study, tags_en: ',  one, two,      three three, ,') }

      it 'sanitizes the tags' do
        expect(case_study.tags_en).to eq('one, two, three three')
      end
    end

    context 'when there are no tags' do
      let!(:case_study_no_tags) { create(:case_study, tags: nil) }

      it 'stores nil' do
        expect(case_study_no_tags.tags_en).to be_nil
        expect(case_study_no_tags.tags_cy).to be_nil
      end
    end
  end

  context 'when attempting to publish with no image' do
    let!(:case_study_no_image) { create(:case_study, image: nil, published: false) }

    it 'raises' do
      case_study_no_image.published = true
      expect { case_study_no_image.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
