require 'rails_helper'

RSpec.describe ActivityTypeFilter, type: :service do
  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:science){ Subject.create(name: 'Science') }
  let!(:maths){ Subject.create(name: 'Maths') }

  let!(:half_hour){ ActivityTiming.create(name: '30 mins') }
  let!(:hour){ ActivityTiming.create(name: 'Hour') }

  let!(:reducing_gas){ Impact.create(name: 'Reducing gas') }
  let!(:reducing_electricity){ Impact.create(name: 'Reducing electricity') }

  let!(:pie_charts){ Topic.create(name: 'Pie charts') }
  let!(:energy){ Topic.create(name: 'Energy') }

  let!(:activity_category_1) { create(:activity_category, name: 'cat1')}
  let!(:activity_category_2) { create(:activity_category, name: 'cat2')}
  let!(:activity_type_1) do
    create(
      :activity_type,
      activity_category: activity_category_1,
      key_stages: [ks1, ks2],
      subjects: [science],
      activity_timings: [half_hour],
      impacts: [reducing_gas],
      other: true
    )
  end
  let!(:activity_type_2) do
    create(
      :activity_type,
      activity_category: activity_category_2,
      key_stages: [ks3],
      subjects: [science, maths],
      activity_timings: [hour],
      topics: [energy],
      impacts: [reducing_gas]
    )
  end
  let!(:activity_type_3) do
    create(
      :activity_type,
      activity_category: activity_category_1,
      key_stages: [ks3],
      subjects: [maths],
      activity_timings: [half_hour],
      topics: [pie_charts],
      impacts: [reducing_gas]
    )
  end

  describe '#selected_key_stages' do

    let(:school){ create(:school, key_stages: [ks1]) }

    context 'when no parameters are passed in' do
      it 'uses the school key stages when a school is set' do
        service = ActivityTypeFilter.new({}, school: school)
        expect(service.selected_key_stages).to match_array([ks1])
      end
      it 'uses none when no school is set' do
        service = ActivityTypeFilter.new({}, school: nil)
        expect(service.selected_key_stages).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the key stages from the ids' do
        service = ActivityTypeFilter.new({key_stage_ids: [ks2.id]}, school: school)
        expect(service.selected_key_stages).to match_array([ks2])
      end
    end
  end

  describe '#selected_key_stages' do

    let(:school){ create(:school, key_stages: [ks1]) }

    context 'when no parameters are passed in' do
      it 'uses the school key stages when a school is set' do
        service = ActivityTypeFilter.new({}, school: school)
        expect(service.selected_key_stages).to match_array([ks1])
      end
      it 'uses none when no school is set' do
        service = ActivityTypeFilter.new({}, school: nil)
        expect(service.selected_key_stages).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the key stages from the ids' do
        service = ActivityTypeFilter.new({key_stage_ids: [ks2.id]}, school: school)
        expect(service.selected_key_stages).to match_array([ks2])
      end
    end
  end

  describe '#selected_subjects' do
    context 'when no parameters are passed in' do
      it 'uses none' do
        service = ActivityTypeFilter.new({})
        expect(service.selected_subjects).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the subjects from the ids' do
        service = ActivityTypeFilter.new({subject_ids: [science.id]})
        expect(service.selected_subjects).to match_array([science])
      end
    end
  end

  describe '#selected_topics' do
    context 'when no parameters are passed in' do
      it 'uses none' do
        service = ActivityTypeFilter.new({})
        expect(service.selected_topics).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the topics from the ids' do
        service = ActivityTypeFilter.new({topic_ids: [pie_charts.id]})
        expect(service.selected_topics).to match_array([pie_charts])
      end
    end
  end

  describe '#selected_activity_timings' do
    context 'when no parameters are passed in' do
      it 'uses none' do
        service = ActivityTypeFilter.new({})
        expect(service.selected_topics).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the timings from the ids' do
        service = ActivityTypeFilter.new({activity_timing_ids: [hour.id]})
        expect(service.selected_activity_timings).to match_array([hour])
      end
    end
  end

  describe '#selected_impacts' do
    context 'when no parameters are passed in' do
      it 'uses none' do
        service = ActivityTypeFilter.new({})
        expect(service.selected_impacts).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the impacts from the ids' do
        service = ActivityTypeFilter.new({impact_ids: [reducing_gas.id]})
        expect(service.selected_impacts).to match_array([reducing_gas])
      end
    end
  end

  describe 'activity_types' do

    subject { ActivityTypeFilter.new(query).activity_types.to_a }

    context 'when a key stage is selected' do
      let(:query){ {key_stage_ids: ks2.id}}
      it { is_expected.to match_array([activity_type_1]) }
    end

    context 'when a subject is selected' do
      let(:query){ {subject_ids: maths.id}}
      it { is_expected.to match_array([activity_type_2, activity_type_3]) }
    end

    context 'when a topic is selected' do
      let(:query){ {topic_ids: pie_charts.id}}
      it { is_expected.to match_array([activity_type_3]) }
    end

    context 'when a timing is selected' do
      let(:query){ {activity_timing_ids: hour.id}}
      it { is_expected.to match_array([activity_type_2]) }
    end

    context 'when an impact is selected' do
      let(:query){ {impact_ids: reducing_electricity.id}}
      it { is_expected.to match_array([]) }
    end

    context 'when nothing is selected, ordering the other activity type last' do
      let(:query){{}}
      it { is_expected.to eq([activity_type_2, activity_type_3, activity_type_1]) }
    end

  end

end
