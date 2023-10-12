require 'rails_helper'

describe ActivityCategory do
  describe '#by_name' do
    let!(:activity_category_1) { create(:activity_category, name: 'Zebras') }
    let!(:activity_category_2) { create(:activity_category, name: 'Antelopes') }

    it 'orders the categories by name based on translated field' do
      expect(ActivityCategory.by_name).to eq([activity_category_2, activity_category_1])
    end
  end

  describe '#listed_with_activity_types' do
    let(:activity_category_1) { create(:activity_category, name: 'Learning') }
    let(:activity_category_2) { create(:activity_category, name: 'Environment') }

    let!(:activity_type_1) { create(:activity_type, name: 'Other', activity_category: activity_category_1, custom: true) }
    let!(:activity_type_2) { create(:activity_type, name: 'Check Temperatures', activity_category: activity_category_1, custom: false) }

    let!(:activity_type_3) { create(:activity_type, name: 'Zoo visit', activity_category: activity_category_2) }
    let!(:activity_type_4) { create(:activity_type, name: 'Alphabet analysis', activity_category: activity_category_2) }

    it 'orders the categories by name and orders the types custom-last by name' do
      expect(ActivityCategory.listed_with_activity_types).to eq(
        [
          [activity_category_2, [activity_type_4, activity_type_3]],
          [activity_category_1, [activity_type_2, activity_type_1]]
        ]
      )
    end
  end

  context 'finding resources for transifex' do
    let!(:activity_category_1) { create(:activity_category, name: 'Learning') }
    let!(:activity_category_2) { create(:activity_category, name: 'Environment') }

    it "#tx_resources" do
      expect(ActivityCategory.tx_resources).to match_array([activity_category_1, activity_category_2])
    end
  end
end
