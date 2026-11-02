# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Tasks::ClassificationTabsComponent, :include_url_helpers, type: :component do
  context 'when viewing an activity classification' do
    before { render_inline(described_class.new(current: 'aim')) }

    it 'shows the activity classification tabs' do
      expect(page).to have_link('Aims', href: admin_activities_labels_path(label_type: 'aim'))
      expect(page).to have_link('Durations', href: admin_activities_labels_path(label_type: 'duration'))
      expect(page).to have_link('Topics', href: admin_activities_labels_path(label_type: 'topic'))
      expect(page).to have_link('Subject areas', href: admin_activities_subject_areas_path)
      expect(page).to have_link('Learning stages', href: admin_activities_learning_stages_path)
    end

    it 'does not show the action classification tabs' do
      expect(page).to have_no_link('Focuses')
    end

    it 'marks the current tab as active' do
      expect(page).to have_css("a.active[href='#{admin_activities_labels_path(label_type: 'aim')}']")
    end

    it 'shows the button for creating a new label' do
      expect(page).to have_link('New aim', href: new_admin_activities_label_path(label_type: 'aim'))
    end
  end

  context 'when viewing a country scoped classification' do
    before { render_inline(described_class.new(current: 'subject_areas', country: :wales)) }

    it 'marks the current tab as active' do
      expect(page).to have_css("a.active[href='#{admin_activities_subject_areas_path(country: :wales)}']")
    end

    it 'links the classification tabs to the country' do
      expect(page).to have_link('Subject areas', href: admin_activities_subject_areas_path(country: :wales))
      expect(page).to have_link('Learning stages', href: admin_activities_learning_stages_path(country: :wales))
    end

    it 'shows the button for creating a new subject area' do
      expect(page).to have_link('New subject area',
                                href: new_admin_activities_subject_area_path(country: :wales))
    end
  end

  context 'when viewing the learning stages' do
    before { render_inline(described_class.new(current: 'learning_stages')) }

    it 'shows the button for creating a new learning stage' do
      expect(page).to have_link('New learning stage', href: new_admin_activities_learning_stage_path)
    end
  end

  context 'when viewing an action classification' do
    before { render_inline(described_class.new(current: 'focus')) }

    it 'shows the action classification tabs' do
      expect(page).to have_link('Focuses', href: admin_activities_labels_path(label_type: 'focus'))
    end

    it 'does not show the activity classification tabs' do
      expect(page).to have_no_link('Aims')
      expect(page).to have_no_link('Subject areas')
    end

    it 'marks the current tab as active' do
      expect(page).to have_css("a.active[href='#{admin_activities_labels_path(label_type: 'focus')}']")
    end

    it 'shows the button for creating a new focus' do
      expect(page).to have_link('New focus', href: new_admin_activities_label_path(label_type: 'focus'))
    end
  end
end
