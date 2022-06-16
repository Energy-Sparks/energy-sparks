require 'rails_helper'

describe 'ActivityType' do

  subject { create :activity_type }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid with invalid attributes' do
    type = build :activity_type, score: -1
    expect( type ).to_not be_valid
    expect( type.errors[:score] ).to include('must be greater than or equal to 0')
  end

  it 'applies live data scope via category' do
    activity_type_1 = create(:activity_type, activity_category: create(:activity_category, live_data: true))
    activity_type_2 = create(:activity_type, activity_category: create(:activity_category, live_data: false))
    expect( ActivityType.live_data ).to match_array([activity_type_1])
  end

  context 'when translations are being applied' do
    let(:old_name) { 'old-name' }
    let(:new_name) { 'new-name' }

    it 'updates original name so search still works' do
      activity_type = create(:activity_type, name: old_name)
      expect(ActivityType.search(new_name)).to eq([])

      activity_type.update(name: new_name)

      expect(activity_type.attributes['name']).to eq(new_name)
      expect(ActivityType.search(new_name)).to eq([activity_type])
    end
  end

  context 'search by query term' do
    it 'finds activities by name' do
      activity_type_1 = create(:activity_type, name: 'foo')
      activity_type_2 = create(:activity_type, name: 'bar')

      expect(ActivityType.search('foo')).to eq([activity_type_1])
      expect(ActivityType.search('bar')).to eq([activity_type_2])
    end

    it 'applies search variants' do
      activity_type_1 = create(:activity_type, name: 'time')
      activity_type_2 = create(:activity_type, name: 'timing')

      expect(ActivityType.search('timing')).to eq([activity_type_1, activity_type_2])
    end
  end

  context 'scoped by key stage' do
    it 'filters activities by key stage' do
      key_stage_1 = create(:key_stage)
      key_stage_2 = create(:key_stage)
      activity_type_1 = create(:activity_type, name: 'KeyStage One', key_stages: [key_stage_1])
      activity_type_2 = create(:activity_type, name: 'KeyStage Two', key_stages: [key_stage_2])
      activity_type_3 = create(:activity_type, name: 'KeyStage One and Two', key_stages: [key_stage_1, key_stage_2])

      expect(ActivityType.for_key_stages([key_stage_1])).to match_array([activity_type_1, activity_type_3])
    end

    it 'does not return duplicates' do
      key_stage_1 = create(:key_stage)
      key_stage_2 = create(:key_stage)
      activity_type_1 = create(:activity_type, name: 'foo one', key_stages: [key_stage_1, key_stage_2])

      expect(ActivityType.for_key_stages([key_stage_1, key_stage_2]).count).to eq(1)
    end
  end

  context 'scoped by subject' do
    it 'filters activities by subject' do
      subject_1 = create(:subject)
      subject_2 = create(:subject)
      activity_type_1 = create(:activity_type, name: 'KeyStage One', subjects: [subject_1])
      activity_type_2 = create(:activity_type, name: 'KeyStage Two', subjects: [subject_2])
      activity_type_3 = create(:activity_type, name: 'KeyStage One and Two', subjects: [subject_1, subject_2])

      expect(ActivityType.for_subjects([subject_1])).to match_array([activity_type_1, activity_type_3])
    end

    it 'does not return duplicates' do
      subject_1 = create(:subject)
      subject_2 = create(:subject)
      activity_type_1 = create(:activity_type, name: 'foo one', subjects: [subject_1, subject_2])

      expect(ActivityType.for_subjects([subject_1, subject_2]).count).to eq(1)
    end
  end

  context 'serialising for transifex' do
    context 'when mapping fields' do
      let!(:activity_type) { create(:activity_type, description: "description", school_specific_description: "Description {{chart}}")}
      it 'produces the expected key names' do
        expect(activity_type.tx_attribute_key(:name)).to eq :name
        expect(activity_type.tx_attribute_key(:description)).to eq :description_html
        expect(activity_type.tx_attribute_key(:school_specific_description)).to eq :school_specific_description_html
        expect(activity_type.tx_attribute_key(:download_links)).to eq :download_links_html
      end
      it 'produces the expected tx values' do
        expect(activity_type.tx_value(:name)).to eql activity_type.name
        expect(activity_type.tx_value(:description)).to eql(
        "<div class=\"trix-content\">\n  description\n</div>\n")
        expect(activity_type.tx_value(:school_specific_description)).to eql("<div class=\"trix-content\">\n  Description %{chart}\n</div>\n")
      end
      it 'produces the expected resource key' do
        expect(activity_type.resource_key).to eq "activity_type_#{activity_type.id}".to_sym
      end
      it 'maps all translated fields' do
        data = activity_type.tx_serialise
        expect(data[:en]).to_not be nil
        key = "activity_type_#{activity_type.id}".to_sym
        expect(data[:en][key]).to_not be nil
        expect(data[:en][key].keys).to match_array([:name, :description_html, :school_specific_description_html, :download_links_html])
      end
      it 'created categories' do
        expect(activity_type.tx_categories).to match_array(["activity_type"])
      end
      it 'fetches status' do
        expect(activity_type.tx_status).to be_nil
        status = TransifexStatus.create_for!(activity_type)
        expect(TransifexStatus.count).to eq 1
        expect(activity_type.tx_status).to eq status
      end
    end
    context 'when updating from transifex' do
      it 'updates simple fields'
      it 'updates HTML fields'
      it 'translates the template syntax'
    end
  end
end
