# frozen_string_literal: true

require 'rails_helper'

describe 'Admin Image Feed' do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit admin_reports_path
  end

  context 'when viewing activities' do
    context 'with no attached images' do
      let!(:activity_no_image) { create(:activity, description: 'Activity no image') }

      before do
        click_on('Images')
      end

      it { expect(page).to have_no_text(activity_no_image.school.name) }
      it { expect(page).to have_text('No results') }
    end

    context 'with images' do
      let(:school_group) { create(:school_group) }

      let!(:activity_with_image) do
        create(:activity_without_creator, :with_image_in_description, school: create(:school, school_group:))
      end

      before do
        click_on('Images')
      end

      it 'has the correct text' do
        expect(find('.g-4').text).to eq(<<~TEXT.chomp)
          #{activity_with_image.school.name}
          Activity ##{activity_with_image.id} #{activity_with_image.activity_type.name}
          Posted #{Date.current}
        TEXT
      end

      context 'when filtering by group' do
        let!(:filtered_activity) do
          create(:activity_without_creator, :with_image_in_description, school: create(:school, :with_school_group))
        end

        before do
          select school_group.name, from: 'School group'
          click_on('Filter')
        end

        it { expect(page).to have_text(activity_with_image.school.name) }
        it { expect(page).to have_no_text(filtered_activity.school.name) }
      end
    end
  end

  context 'when viewing actions' do
    context 'with no attached images' do
      let!(:observation_no_image) { create(:observation, :intervention, description: 'Intervention no image') }

      before do
        click_on('Images')
        select 'Actions', from: 'Type'
        click_on('Filter')
      end

      it { expect(page).to have_no_text(observation_no_image.school.name) }
      it { expect(page).to have_text('No results') }
    end

    context 'with images' do
      let(:school_group) { create(:school_group) }

      let!(:observation_with_image) do
        create(:observation, :intervention_with_image_in_description, school: create(:school, school_group:))
      end

      before do
        click_on('Images')
        select 'Actions', from: 'Type'
        click_on('Filter')
      end

      it { expect(page).to have_text(observation_with_image.school.name) }

      context 'when filtering by group' do
        let!(:filtered_action) do
          create(:observation, :intervention_with_image_in_description, school: create(:school, :with_school_group))
        end

        before do
          select school_group.name, from: 'School group'
          click_on('Filter')
        end

        it { expect(page).to have_text(observation_with_image.school.name) }
        it { expect(page).to have_no_text(filtered_action.school.name) }
      end
    end
  end
end
