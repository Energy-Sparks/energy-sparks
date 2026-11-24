# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::Task, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:country) { :england }
  let(:show_summary) { false }
  let(:summary) { 'Task summary' }
  let(:params) do
    { id: 'custom-id', classes: 'extra-classes', task: task, country: country, show_summary: show_summary }
  end

  let(:task) do
    create(:activity_type, score: 10, summary: summary,
                           learning_stages: [learning_stage],
                           subject_areas: [subject_area],
                           durations: [duration])
  end
  let(:learning_stage) do
    create(:learning_stage, name: 'Key Stage 1', abbreviation: 'KS1', country: country)
  end
  let(:subject_area) { create(:subject_area, name: 'Science', country: country) }
  let(:duration) { create(:label, label_type: :duration, name: 'Under 30 mins') }

  before { render_inline(component) }

  context 'with an activity type' do
    it_behaves_like 'an application component' do
      let(:expected_classes) { 'extra-classes' }
      let(:expected_id) { 'custom-id' }
    end

    it_behaves_like 'a layout component' do
      let(:expected_theme) { :accent }
    end

    it 'wraps the card in a link to the task' do
      expect(page).to have_css("a[href='#{activity_type_path(task)}'] .card")
    end

    it 'renders the task name' do
      expect(page).to have_text(task.name)
    end

    it 'renders the task image' do
      expect(page).to have_css('img.card-img-top')
    end

    it 'does not render the summary by default' do
      expect(page).to have_no_text(summary)
    end

    it 'shows the points' do
      expect(page).to have_css('.badge', text: I18n.t('nav.points', count: task.score))
    end

    it 'shows the learning stage' do
      expect(page).to have_css('.badge', text: learning_stage.abbreviation)
    end

    it 'has the learning stage tooltip' do
      expect(page).to have_css("[title='#{learning_stage.name}']")
    end

    it 'shows the subject area' do
      expect(page).to have_css('.badge', text: subject_area.name)
    end

    it 'has subject area tooltip' do
      expect(page).to have_css("[title='Subject']")
    end

    it 'shows the duration' do
      expect(page).to have_css('.badge', text: duration.name)
    end

    it 'has duration tooltip' do
      expect(page).to have_css("[title='#{I18n.t('activity_types.duration')}']")
    end
  end

  context 'with the summary switched on' do
    let(:show_summary) { true }

    it 'renders the summary' do
      expect(page).to have_text(summary)
    end
  end

  context 'with an intervention type' do
    let(:task) { create(:intervention_type, score: 30) }

    it_behaves_like 'a layout component' do
      let(:expected_theme) { :light }
    end

    it 'wraps the card in a link to the intervention type' do
      expect(page).to have_css("a[href='#{intervention_type_path(task)}'] .card")
    end

    it 'shows the points' do
      expect(page).to have_css('.badge', text: I18n.t('nav.points', count: task.score))
    end

    it 'does not render activity classifications' do
      expect(page).to have_no_css('.badge', text: 'KS1')
    end
  end

  context 'with a Scottish task' do
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
      create(:activity_type, score: 10, summary: summary,
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

  context 'without a country' do
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
