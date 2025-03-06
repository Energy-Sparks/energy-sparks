require 'rails_helper'

RSpec.describe ProgrammeType, type: :model do
  describe '#tx_resources' do
    let!(:programme_type_1) { create(:programme_type, active: true, title: 'one') }
    let!(:programme_type_2) { create(:programme_type, active: false, title: 'two') }

    it 'contains active programme types' do
      expect(ProgrammeType.tx_resources).to match_array([programme_type_1])
    end
  end

  describe 'bonus score validations' do
    it 'has a valid bonus score that is equal to or greater than zero' do
      expect(ProgrammeType.new(active: true, title: 'one', bonus_score: 0)).to be_valid
      expect(ProgrammeType.new(active: true, title: 'one', bonus_score: 100)).to be_valid
      expect(ProgrammeType.new(active: true, title: 'one', bonus_score: -1)).not_to be_valid
      expect(ProgrammeType.new(active: true, title: 'one', bonus_score: nil)).not_to be_valid
    end
  end

  describe '#document_link' do
    let!(:programme_type_1) { create(:programme_type, active: true, title: 'one', document_link: 'en-doc') }

    it 'gives en version by default' do
      expect(programme_type_1.document_link).to eq('en-doc')
    end

    it 'gives en version if no cy version' do
      I18n.with_locale(:cy) do
        expect(programme_type_1.document_link).to eq('en-doc')
      end
    end

    it 'gives cy version if provided' do
      programme_type_1.update(document_link_cy: 'cy-doc')
      I18n.with_locale(:cy) do
        expect(programme_type_1.document_link).to eq('cy-doc')
      end
    end
  end

  describe '#activity_type_ids_for_school' do
    let!(:programme_type) { create(:programme_type_with_activity_types) }
    let!(:school) { create(:school) }

    subject(:activity_type_ids_for_school) { programme_type.activity_type_ids_for_school(school) }

    context 'when no activities have been completed' do
      it 'is empty' do
        expect(activity_type_ids_for_school).to be_empty
      end
    end

    context 'when one activity has been completed' do
      before do
        create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: Time.zone.now)
      end

      it 'contains that activity type' do
        expect(activity_type_ids_for_school).to eq([programme_type.activity_types.first.id])
      end
    end

    context 'when school has completed all activities in programme type' do
      before do
        programme_type.activity_types.each do |activity_type|
          create(:activity, school: school, activity_type: activity_type, happened_on: Time.zone.now)
        end
      end

      it 'contains all completed activity types for programme type' do
        expect(activity_type_ids_for_school).to eq(programme_type.activity_types.ids)
      end

      context 'when an activity has been completed twice' do
        before do
          create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: Time.zone.now)
        end

        it 'contains all completed activity types for programme type' do
          expect(activity_type_ids_for_school).to eq(programme_type.activity_types.ids)
        end
      end
    end
  end

  describe '#all_activity_types_completed_for_school?' do
    let!(:programme_type) { create(:programme_type_with_activity_types) }
    let!(:school) { create(:school) }

    subject(:all_activity_types_completed_for_school) { programme_type.all_activity_types_completed_for_school?(school) }

    context 'when no activities have been completed' do
      it { expect(all_activity_types_completed_for_school).to be false }
    end

    context 'when one activity has been completed' do
      before do
        create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: Time.zone.now)
      end

      it { expect(all_activity_types_completed_for_school).to be false }
    end

    context 'when school has completed all activities in programme type' do
      before do
        programme_type.activity_types.each do |activity_type|
          create(:activity, school: school, activity_type: activity_type, happened_on: Time.zone.now)
        end
      end

      it { expect(all_activity_types_completed_for_school).to be true }

      context 'when an activity has been completed twice' do
        before do
          create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: Time.zone.now)
        end

        it { expect(all_activity_types_completed_for_school).to be true }
      end
    end
  end

  it_behaves_like 'an assignable' do
    subject(:assignable) { create(:programme_type) }
  end
end
