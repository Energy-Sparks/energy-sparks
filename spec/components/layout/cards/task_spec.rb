# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::Task, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:country) { :england }
  let(:params) do
    { id: 'custom-id', classes: 'extra-classes', task: task, country: country, show_summary: false }
  end

  let(:task) do
    create(:activity_type, score: 10, summary: 'Task summary',
                           learning_stages: [learning_stage],
                           key_stages: [key_stage],
                           subject_areas: [subject_area],
                           subjects: [old_subject],
                           durations: [duration])
  end
  let(:learning_stage) do
    create(:learning_stage, name: 'Key Stage 1', abbreviation: 'KS1', country: country)
  end
  let(:key_stage) { create(:key_stage, name: 'KS2') }
  let(:subject_area) { create(:subject_area, name: 'Science', country: country) }
  let(:old_subject) { create(:subject, name: 'Humanities') }
  let(:duration) { create(:label, label_type: :duration, name: 'Under 30 mins') }

  shared_examples 'a task card with shared behavior' do
    it 'shows the task name' do
      expect(page).to have_text(task.name)
    end

    it 'shows the task image' do
      expect(page).to have_css('img.card-img-top')
    end

    it 'does not show the summary by default' do
      expect(page).to have_no_text(task.summary)
    end

    it 'shows the points' do
      expect(page).to have_css('.badge', text: I18n.t('nav.points', count: task.score))
    end
  end

  context 'with an activity type', with_feature: :activities_index do
    before { render_inline(component) }

    it_behaves_like 'an application component' do
      let(:expected_classes) { 'extra-classes' }
      let(:expected_id) { 'custom-id' }
    end

    it_behaves_like 'a layout component' do
      let(:expected_theme) { :accent }
    end

    it_behaves_like 'a task card with shared behavior'

    it 'links the activity type' do
      expect(page).to have_css("a[href='#{activity_type_path(task)}'] .card")
    end

    it 'shows the points tooltip' do
      expect(page).to have_css("[title='#{I18n.t('tasks.points.activity')}']")
    end

    it 'shows the duration' do
      expect(page).to have_css('.badge', text: duration.name)
      expect(page).to have_css("[title='#{I18n.t('activity_types.duration')}']")
    end
  end

  context 'with new classifications', with_feature: :activities_index do
    before { render_inline(component) }

    it 'shows the learning stage' do
      expect(page).to have_css('.badge', text: learning_stage.abbreviation)
      expect(page).to have_css("[title='#{learning_stage.name}']")
    end

    it 'shows the subject area' do
      expect(page).to have_css('.badge', text: subject_area.name)
      expect(page).to have_css("[title='#{I18n.t('activity_types.subject_area_label.england')}']")
    end

    it 'does not show old classifications' do
      expect(page).to have_no_css('.badge', text: key_stage.name)
      expect(page).to have_no_css('.badge', text: old_subject.name)
    end
  end

  context 'with old classifications', without_feature: :activities_index do
    before { render_inline(component) }

    it 'shows the key stage' do
      expect(page).to have_css('.badge', text: I18n.t(key_stage.i18n_key))
      expect(page).to have_css("[title='#{I18n.t('activity_types.key_stages')}']")
    end

    it 'shows the subject' do
      expect(page).to have_css('.badge', text: I18n.t(old_subject.i18n_key))
      expect(page).to have_css("[title='#{I18n.t('activity_types.subjects')}']")
    end

    it 'does not show new classifications' do
      expect(page).to have_no_css('.badge', text: learning_stage.abbreviation)
      expect(page).to have_no_css('.badge', text: subject_area.name)
      expect(page).to have_no_css('.badge', text: duration.name)
    end
  end

  context 'with the summary switched on' do
    before { render_inline(component) }

    let(:params) { super().merge(show_summary: true) }

    it 'shows the summary' do
      expect(page).to have_text(task.summary)
    end
  end

  context 'with an action', with_feature: :activities_index do
    before { render_inline(component) }

    let(:task) { create(:intervention_type, score: 30) }

    it_behaves_like 'a layout component' do
      let(:expected_theme) { :light }
    end

    it_behaves_like 'a task card with shared behavior'

    it 'links to the intervention type' do
      expect(page).to have_css("a[href='#{intervention_type_path(task)}'] .card")
    end

    it 'shows the points tooltip' do
      expect(page).to have_css("[title='#{I18n.t('tasks.points.action')}']")
    end

    it 'does not render activity classifications' do
      expect(page).to have_no_css('.badge', text: learning_stage.abbreviation)
    end
  end

  context 'with a Scottish activity', with_feature: :activities_index do
    before { render_inline(component) }

    let(:country) { :scotland }
    let(:learning_stage) do
      create(:learning_stage, name: 'First Level', abbreviation: 'First', country: :scotland)
    end
    let(:subject_area) { create(:subject_area, name: 'Social studies', country: :scotland) }
    let(:england_learning_stage) do
      create(:learning_stage, name: 'Key Stage 1', abbreviation: 'KS1', country: :england)
    end
    let(:england_subject_area) { create(:subject_area, name: 'Geography', country: :england) }
    let(:task) do
      create(:activity_type, score: 10, summary: 'Task summary',
                             learning_stages: [learning_stage, england_learning_stage],
                             subject_areas: [subject_area, england_subject_area],
                             durations: [duration])
    end

    it 'shows the learning stage abbreviation' do
      expect(page).to have_css('.badge', text: learning_stage.abbreviation)
    end

    it 'has the learning stage tooltip' do
      expect(page).to have_css("[title='#{learning_stage.name}']")
    end

    it 'has the curriculum area tooltip' do
      expect(page).to have_css("[title='Curriculum area']")
    end

    it 'does not show learning stages for other countries' do
      expect(page).to have_no_css('.badge', text: england_learning_stage.abbreviation)
    end

    it 'does not show subject areas for other countries' do
      expect(page).to have_no_css('.badge', text: england_subject_area.name)
    end
  end

  context 'without a country', with_feature: :activities_index do
    before { render_inline(component) }

    let(:params) { { task: task } }

    it 'defaults to England' do
      expect(page).to have_css('.badge', text: learning_stage.abbreviation)
    end
  end

  describe '#initialize' do
    context 'with an unsupported country' do
      it 'raises an error' do
        expect { described_class.new(task: task, country: :france) }
          .to raise_error(ArgumentError, /not a permitted value/)
      end
    end
  end
end
