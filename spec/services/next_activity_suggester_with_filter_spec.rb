require 'rails_helper'

describe NextActivitySuggesterWithFilter do

  let!(:academic_year_start) { Date.today - 6.months }
  let!(:academic_year_end) { Date.today + 6.months }
  let!(:academic_year) { create(:academic_year, start_date: academic_year_start, end_date: academic_year_end) }
  let!(:calendar) { create(:calendar, academic_years: [academic_year]) }

  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:maths) { Subject.create(name: 'Maths') }

  #school key stages should be ignored now, filtering will only look at any
  #existing activities
  let!(:school) { create :school, key_stages: [ks1, ks3], calendar: calendar }

  let(:activity_type_filter){ ActivityTypeFilter.new(school: school)}

  subject { NextActivitySuggesterWithFilter.new(school, activity_type_filter) }

  describe '.suggest_from_activity_history' do
    context "school has no activities and there are no initial suggestions rely on top up" do
      let!(:activity_types_for_ks1_ks2) { create_list(:activity_type, 3, key_stages: [ks1, ks2])}
      let!(:activity_types_for_ks2)     { create_list(:activity_type, 3, key_stages: [ks2])}

      let(:no_activity_types_set_or_initial_expected) { activity_types_for_ks1_ks2 + activity_types_for_ks2 }

      it "suggests a random sample" do
        #suggestions are just the 6 activities in the system, as there are no activities recorded
        #for this school, or any "initial" activities in the database
        expect(subject.suggest_from_activity_history).to match_array(no_activity_types_set_or_initial_expected)
      end

    end

    context "school has no activities and there are initial suggestions" do

      let!(:activity_types_with_suggestions_for_ks1_ks2) { create_list(:activity_type, 3, :as_initial_suggestions, key_stages: [ks1, ks2])}
      let!(:activity_types_with_suggestions_for_ks2)     { create_list(:activity_type, 3, :as_initial_suggestions, key_stages: [ks2])}
      let!(:activity_types_with_suggestions_for_ks3)     { create_list(:activity_type, 2, :as_initial_suggestions, key_stages: [ks3], subjects: [maths])}

      let(:activity_types_with_suggestions) { activity_types_with_suggestions_for_ks1_ks2 + activity_types_with_suggestions_for_ks2 + activity_types_with_suggestions_for_ks3 }

      it "suggests the initial suggestions, ignoring school key stages" do
       expect(subject.suggest_from_activity_history).to match_array(activity_types_with_suggestions)
      end

      context 'where the filter restricts the available activities' do
        let(:activity_type_filter){ ActivityTypeFilter.new(query: {subject_ids: [maths.id]}, school: school)}
        it 'applies the subject filter' do
          expect(subject.suggest_from_activity_history).to match_array(activity_types_with_suggestions_for_ks3)
        end
      end
    end

    context "with suggestions based on last activity type" do

      let!(:activity_type_with_further_suggestions)   { create :activity_type, :with_further_suggestions, number_of_suggestions: 6, key_stages: [ks1, ks3]}
      let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

      it "suggests the six follow ons from original" do
        expect(subject.suggest_from_activity_history).to match_array(activity_type_with_further_suggestions.suggested_types)
      end
    end

    context "with suggestions based on last activity type" do
      # ensure there are enough suggestions that we don't need to pick random extras, once we've excluded activities done this year..
      let!(:number_of_suggestions) { NextActivitySuggesterWithFilter::NUMBER_OF_SUGGESTIONS + 1 }
      let!(:activity_type_with_further_suggestions)   { create :activity_type, :with_further_suggestions, number_of_suggestions: number_of_suggestions, key_stages: [ks1, ks3]}
      let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

      it "suggests only the follow-on activities that haven't been done this academic year" do
        repeatable_done = activity_type_with_further_suggestions.suggested_types.second
        activity = create(:activity, activity_type: repeatable_done, school: school, happened_on: academic_year_start - 1.month, created_at: academic_year_start - 1.month)

        non_repeatable_done = activity_type_with_further_suggestions.suggested_types.third
        non_repeatable_done.update( name: 'DROP ME' )
        activity = create(:activity, activity_type: non_repeatable_done, school: school, happened_on: academic_year_start + 1.month, created_at: academic_year_start + 1.month)

        result = subject.suggest_from_activity_history
        activity_type_with_further_suggestions.reload
        expected = activity_type_with_further_suggestions.suggested_types.reject {|ats| ats.id == non_repeatable_done.id }

        expect(result).to match_array(expected)
      end
    end
  end

  describe '.suggest_from_programmes' do

    let!(:programme_type)  { create :programme_type_with_activity_types }
    let!(:programme)      { Programmes::Creator.new(school, programme_type).create }
    let(:activity_types)  { programme_type.activity_types }

    let!(:ks1_activity_type){ activity_types[0].tap{|activity_type| activity_type.update!(key_stages: [ks1])} }
    let!(:ks2_activity_type){ activity_types[1].tap{|activity_type| activity_type.update!(key_stages: [ks2])} }
    let!(:ks3_activity_type){ activity_types[2].tap{|activity_type| activity_type.update!(key_stages: [ks3])} }

    it 'returns the activity types' do
      result = subject.suggest_from_programmes
      expect(result).to match_array([ks1_activity_type, ks2_activity_type, ks3_activity_type])
    end

    context 'where the programme has finished' do
      it 'does not use the activity types' do
        programme.complete!
        expect(subject.suggest_from_programmes).to be_empty
      end
    end

    context 'where the school has completed the activity' do
      it 'does not use the activity type' do
        create(:activity, activity_type: ks1_activity_type, school: school)
        expect(subject.suggest_from_programmes).to match_array([ks2_activity_type, ks3_activity_type])
      end
    end
  end

  describe '.suggest_from_find_out_mores' do

    let!(:activity_type){ create(:activity_type, name: 'Turn off the heating', key_stages: [ks1]) }
    let!(:alert_type_rating) do
      create(
        :alert_type_rating,
        find_out_more_active: true,
        activity_types: [activity_type]
      )
    end
    let!(:alert_type_rating_content_version) do
      create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating)
    end
    let!(:alert) do
      create(:alert, :with_run,
        alert_type: alert_type_rating.alert_type,
        run_on: Time.zone.today, school: school,
        rating: 9.0
      )
    end

    context 'where there is a content generation run' do
      before do
        Alerts::GenerateContent.new(school).perform
      end

      it 'returns activity types from the alerts' do
        result = subject.suggest_from_find_out_mores
        expect(result).to match_array([activity_type])
      end

    end

    context 'where there is no content' do
      it 'returns no activity types' do
        result = subject.suggest_from_find_out_mores
        expect(result).to match_array([])
      end
    end

  end

  describe '.suggest_for_school_targets' do
    #3 in programme
    let!(:programme_type)  { create :programme_type_with_activity_types }
    let!(:programme)      { Programmes::Creator.new(school, programme_type).create }
    let(:activity_types)  { programme_type.activity_types }

    let!(:ks1_activity_type){ activity_types[0].tap{|activity_type| activity_type.update!(key_stages: [ks1])} }

    it 'suggests from programmes first' do
      suggestions = subject.suggest_for_school_targets(1)
      expect(suggestions).to match_array([ks1_activity_type])
    end

    it 'suggests other activities as a fallback' do
      suggestions = subject.suggest_for_school_targets(3)
      expect(suggestions).to match_array(programme_type.activity_types)
    end

  end

  describe '.suggest_from_audits' do
    let!(:audit) { create(:audit, :with_activity_and_intervention_types, title: "Our audit", description: "Description of the audit", school: school) }

    it 'suggests from an audit' do
      suggestions = subject.suggest_from_audits
      expect(suggestions).to match_array(audit.activity_types)
    end

    it 'doesnt suggest if completed' do
      activity = create(:activity, activity_type: audit.audit_activity_types.first.activity_type, school: school)
      suggestions = subject.suggest_from_audits
      expect(suggestions.count).to eql 2
    end
  end
end
