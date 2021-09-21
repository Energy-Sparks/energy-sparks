require 'rails_helper'

RSpec.describe ActivityTypeFilter, type: :service do
  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:science){ Subject.create(name: 'Science') }
  let!(:maths){ Subject.create(name: 'Maths') }

  let!(:half_hour){ ActivityTiming.create(name: '30 mins', position: 0) }
  let!(:hour){ ActivityTiming.create(name: 'Hour', position: 1, include_lower: true) }

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
      custom: true
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
        service = ActivityTypeFilter.new(school: school)
        expect(service.selected_key_stages).to match_array([ks1])
      end
      it 'uses none when no school is set' do
        service = ActivityTypeFilter.new(school: nil)
        expect(service.selected_key_stages).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the key stages from the ids' do
        service = ActivityTypeFilter.new(query: {key_stage_ids: [ks2.id]}, school: school)
        expect(service.selected_key_stages).to match_array([ks2])
      end
    end
  end

  describe '#selected_subjects' do
    context 'when no parameters are passed in' do
      it 'uses none' do
        service = ActivityTypeFilter.new()
        expect(service.selected_subjects).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the subjects from the ids' do
        service = ActivityTypeFilter.new(query: {subject_ids: [science.id]})
        expect(service.selected_subjects).to match_array([science])
      end
    end
  end

  describe '#selected_topics' do
    context 'when no parameters are passed in' do
      it 'uses none' do
        service = ActivityTypeFilter.new
        expect(service.selected_topics).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the topics from the ids' do
        service = ActivityTypeFilter.new(query: {topic_ids: [pie_charts.id]})
        expect(service.selected_topics).to match_array([pie_charts])
      end
    end
  end

  describe '#selected_activity_timings' do

    context 'when no parameters are passed in' do
      it 'uses none' do
        service = ActivityTypeFilter.new
        expect(service.selected_topics).to match_array([])
      end
    end

    context 'when parameters are passed in' do
      it 'loads the timings from the ids' do
        service = ActivityTypeFilter.new(query: {activity_timing_ids: [half_hour.id]})
        expect(service.selected_activity_timings).to match_array([half_hour])
      end
      it 'includes lower timings when selected' do
        service = ActivityTypeFilter.new(query: {activity_timing_ids: [hour.id]})
        expect(service.selected_activity_timings).to match_array([half_hour, hour])
      end
    end
  end

  describe '#selected_impacts' do
    context 'when no parameters are passed in' do
      it 'uses none' do
        service = ActivityTypeFilter.new
        expect(service.selected_impacts).to match_array([])
      end
    end
    context 'when parameters are passed in' do
      it 'loads the impacts from the ids' do
        service = ActivityTypeFilter.new(query: {impact_ids: [reducing_gas.id]})
        expect(service.selected_impacts).to match_array([reducing_gas])
      end
    end
  end

  describe 'activity_types' do

    subject { ActivityTypeFilter.new(query: query).activity_types.to_a }

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
      let(:query){ {activity_timing_ids: half_hour.id}}
      it { is_expected.to match_array([activity_type_1, activity_type_3]) }
    end

    context 'when an impact is selected' do
      let(:query){ {impact_ids: reducing_electricity.id}}
      it { is_expected.to match_array([]) }
    end

    context 'when nothing is selected' do
      let(:query){{}}

      it 'should have custom activity type last' do
        expect(subject.last).to eq activity_type_1
      end

      it 'includes the active activity types only' do
        activity_type_1.update!(active: false)
        expect(subject).to match_array [activity_type_2, activity_type_3]
      end
    end

    context 'with a custom scope' do
      it 'uses the scope' do
        expect(ActivityTypeFilter.new(scope: ActivityType.none).activity_types).to be_empty
      end
    end
  end

  describe 'exclude_if_done_this_year' do

    let(:academic_year){ create(:academic_year, start_date: '2019-09-01', end_date: '2020-08-31') }
    let(:calendar){ create(:calendar, academic_years: [academic_year]) }
    let(:school){ create(:school, calendar: calendar) }

    subject { ActivityTypeFilter.new(school: school, query: {exclude_if_done_this_year: true}, current_date: Date.parse('2020-04-01')).activity_types.to_a }

    before do
      create(:activity, activity_type: activity_type_1, school: school, happened_on: '2019-01-01')
      create(:activity, activity_type: activity_type_2, school: school, happened_on: '2020-01-01')
    end

    it 'excludes activity types where activity was completed within the academic year' do
      expect(subject).to match_array([activity_type_1, activity_type_3])
    end

  end

end
