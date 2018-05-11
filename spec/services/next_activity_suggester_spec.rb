require 'rails_helper'

describe NextActivitySuggester do
  let(:school) { school = create :school, enrolled: true }
  let(:activity_category) { create :activity_category }
  let!(:activity_types) { create_list(:activity_type, 5, activity_category: activity_category, data_driven: true) }

  context "with no activity types set for the school" do
    subject { NextActivitySuggester.new(school, true) }
    it "suggests any 5 if no suggestions" do
      expect(subject.suggest).to match_array(activity_types)
    end
  end

  context "with initial suggestions" do
    let!(:activity_types_with_suggestions) { create_list(:activity_type, 5, :as_initial_suggestions)}
    subject { NextActivitySuggester.new(school, true) }

    it "suggests the first five initial suggestions" do
     expect(subject.suggest).to match_array(activity_types_with_suggestions)
    end
  end

  context "with suggestions based on last activity type" do
    subject { NextActivitySuggester.new(school) }
    let!(:activity_type_with_further_suggestions) { create :activity_type, :with_further_suggestions, number_of_suggestions: 5 }
    let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

    it "suggests the five follow ons from original" do
      expect(subject.suggest).to match_array(last_activity.activity_type.activity_type_suggestions.map(&:suggested_type))
    end
  end
end