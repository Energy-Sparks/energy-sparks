require 'rails_helper'

describe NextActivitySuggesterWithKeyStages do

  let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
  let!(:ks2_tag) { ActsAsTaggableOn::Tag.create(name: 'KS2') }
  let!(:ks3_tag) { ActsAsTaggableOn::Tag.create(name: 'KS3') }

  let!(:activity_types_for_ks1_ks2) { create_list(:activity_type, 3, key_stages: [ks1_tag, ks2_tag])}
  let!(:activity_types_for_ks2)     { create_list(:activity_type, 3, key_stages: [ks2_tag])}
  let!(:activity_types_for_ks3)     { create_list(:activity_type, 2, key_stages: [ks1_tag, ks2_tag])}

  let(:no_activity_types_set_or_inital_expected) { activity_types_for_ks1_ks2 + activity_types_for_ks3 }
  let!(:school) { create :school, enrolled: true, key_stages: [ks1_tag, ks3_tag] }

  context "with no activity types set for the school nor any initial suggestions rely on top up" do
    subject { NextActivitySuggesterWithKeyStages.new(school) }
    it "suggests any 5 if no suggestions" do
      expect(subject.suggest).to match_array(no_activity_types_set_or_inital_expected)
    end
  end

  context "with initial suggestions" do

    let!(:activity_types_with_suggestions_for_ks1_ks2) { create_list(:activity_type, 3, :as_initial_suggestions, key_stages: [ks1_tag, ks2_tag])}
    let!(:activity_types_with_suggestions_for_ks2)     { create_list(:activity_type, 3, :as_initial_suggestions, key_stages: [ks2_tag])}
    let!(:activity_types_with_suggestions_for_ks3)     { create_list(:activity_type, 2, :as_initial_suggestions, key_stages: [ks1_tag, ks2_tag])}

    let(:activity_types_with_suggestions) { activity_types_with_suggestions_for_ks1_ks2 + activity_types_with_suggestions_for_ks3 }

    subject { NextActivitySuggesterWithKeyStages.new(school) }
    it "suggests the first five initial suggestions" do
     expect(subject.suggest).to match_array(activity_types_with_suggestions)
    end
  end

  context "with suggestions based on last activity type" do

    let!(:activity_type_with_further_suggestions)   { create :activity_type, :with_further_suggestions, number_of_suggestions: 6, key_stages: [ks1_tag, ks3_tag]}
    let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

    subject { NextActivitySuggesterWithKeyStages.new(school) }

    it "suggests the five follow ons from original" do
      ks2_this_one = activity_type_with_further_suggestions.suggested_types.third
      ks2_this_one.update(key_stages: [ks2_tag], name: 'DROP ME')

      activity_type_with_further_suggestions.suggested_types.order(:id).each { |st| pp st.key_stages }

      result = subject.suggest
      expected = activity_type_with_further_suggestions.suggested_types.reject {|ats| ats.id == ks2_this_one.id }

      expect(result).to match_array(expected)
    end
  end
end