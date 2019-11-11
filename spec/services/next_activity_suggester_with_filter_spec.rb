require 'rails_helper'

describe NextActivitySuggesterWithFilter do

  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:maths) { Subject.create(name: 'Maths') }
  let!(:school) { create :school, key_stages: [ks1, ks3] }

  let(:activity_type_filter){ ActivityTypeFilter.new(school: school)}

  subject { NextActivitySuggesterWithFilter.new(school, activity_type_filter) }

  describe '.suggest_from_activity_history' do
    context "with no activity types set for the school nor any initial suggestions rely on top up" do
      let!(:activity_types_for_ks1_ks2) { create_list(:activity_type, 3, key_stages: [ks1, ks2])}
      let!(:activity_types_for_ks2)     { create_list(:activity_type, 3, key_stages: [ks2])}
      let!(:activity_types_for_ks3)     { create_list(:activity_type, 2, key_stages: [ks3])}

      let(:no_activity_types_set_or_inital_expected) { activity_types_for_ks1_ks2 + activity_types_for_ks3 }

      it "suggests any 6 if no suggestions using the filter" do
        expect(subject.suggest_from_activity_history).to match_array(no_activity_types_set_or_inital_expected)
      end
    end

    context "with initial suggestions" do

      let!(:activity_types_with_suggestions_for_ks1_ks2) { create_list(:activity_type, 3, :as_initial_suggestions, key_stages: [ks1, ks2])}
      let!(:activity_types_with_suggestions_for_ks2)     { create_list(:activity_type, 3, :as_initial_suggestions, key_stages: [ks2])}
      let!(:activity_types_with_suggestions_for_ks3)     { create_list(:activity_type, 2, :as_initial_suggestions, key_stages: [ks1, ks2], subjects: [maths])}

      let(:activity_types_with_suggestions) { activity_types_with_suggestions_for_ks1_ks2 + activity_types_with_suggestions_for_ks3 }

      it "suggests the first five initial suggestions" do
       expect(subject.suggest_from_activity_history).to match_array(activity_types_with_suggestions)
      end

      context 'where the filter restricts the available activities' do
        let(:activity_type_filter){ ActivityTypeFilter.new(query: {subject_ids: [maths.id]}, school: school)}
        it 'does not top up with duplicate activity types' do
          expect(subject.suggest_from_activity_history).to match_array(activity_types_with_suggestions_for_ks3)
        end
      end
    end

    context "with suggestions based on last activity type" do

      let!(:activity_type_with_further_suggestions)   { create :activity_type, :with_further_suggestions, number_of_suggestions: 6, key_stages: [ks1, ks3]}
      let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

      it "suggests the five follow ons from original" do
        ks2_this_one = activity_type_with_further_suggestions.suggested_types.third
        ks2_this_one.update(key_stages: [ks2], name: 'DROP ME')

        result = subject.suggest_from_activity_history
        expected = activity_type_with_further_suggestions.suggested_types.reject {|ats| ats.id == ks2_this_one.id }

        expect(result).to match_array(expected)
      end
    end

    context "with suggestions based on last activity type" do

      let!(:activity_type_with_further_suggestions)   { create :activity_type, :with_further_suggestions, number_of_suggestions: 6, key_stages: [ks1, ks3]}
      let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

      it "suggests the five follow ons from original" do
        repeatable_done = activity_type_with_further_suggestions.suggested_types.second
        activity = create(:activity, activity_type: repeatable_done, school: school)

        non_repeatable_done = activity_type_with_further_suggestions.suggested_types.third
        non_repeatable_done.update( name: 'DROP ME', repeatable: false)
        activity = create(:activity, activity_type: non_repeatable_done, school: school)

        result = subject.suggest_from_activity_history
        activity_type_with_further_suggestions.reload
        expected = activity_type_with_further_suggestions.suggested_types.reject {|ats| ats.id == non_repeatable_done.id }

        expect(result).to match_array(expected)
      end
    end
  end

  describe '.suggest_from_programmes' do

    let(:programme_type)  { create :programme_type_with_activity_types }
    let!(:programme)      { Programmes::Creator.new(school, programme_type).create }
    let(:activity_types)  { programme_type.activity_types }

    let(:ks1_activity_type){ activity_types[0].tap{|activity_type| activity_type.update!(key_stages: [ks1])} }
    let(:ks2_activity_type){ activity_types[1].tap{|activity_type| activity_type.update!(key_stages: [ks2])} }
    let(:ks3_activity_type){ activity_types[2].tap{|activity_type| activity_type.update!(key_stages: [ks3])} }

    it 'filters the activity types' do
      result = subject.suggest_from_programmes
      expect(result).to match_array([ks1_activity_type, ks3_activity_type])
    end

    context 'where the programme has finished' do
      it 'does not use the activity types' do
        programme.completed!
        expect(subject.suggest_from_programmes).to be_empty
      end
    end

    context 'where the school has completed the activity' do
      it 'does not use the activity type' do
        programme.programme_activities.where(activity_type: ks1_activity_type).first.update!(activity: create(:activity, activity_type: ks1_activity_type, school: school))
        expect(subject.suggest_from_programmes).to match_array([ks3_activity_type])
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
      Alert.create(
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

      it 'filters on key stage' do
        activity_type.update!(key_stages: [ks2])
        result = subject.suggest_from_find_out_mores
        expect(result).to match_array([])
      end
    end

    context 'where there is no content' do
      before do
        Alerts::GenerateContent.new(school).perform
      end

      it 'returns no activity types' do
        activity_type.update!(key_stages: [ks2])
        result = subject.suggest_from_find_out_mores
        expect(result).to match_array([])
      end
    end

  end
end
