require 'rails_helper'

describe 'Recommendations Page', type: :system, include_application_helper: true do
  let(:key_stage_1) { create :key_stage, name: 'KS1'}
  let!(:school) { create :school, name: 'School Name', key_stages: [key_stage_1] }
  let!(:programme_type) { }

  let!(:setup_data) {}
  let(:user) {}

  shared_examples_for 'a panel selector with scope' do
    %i[pupil student].each do |role|
      context "when current user is #{role}" do
        let(:user) { create(role) }

        it 'has pupil checked' do
          expect(section).to have_checked_field('Pupil activities')
        end
      end
    end

    context 'when current user is staff' do
      let(:user) { create(:staff) }

      it 'has pupil checked' do
        expect(section).to have_checked_field('Pupil activities')
      end
    end

    context 'when current user is not staff or pupil' do
      let(:user) { create(:school_admin) }

      it 'has adult checked' do
        expect(section).to have_checked_field('Adult actions')
      end
    end

    context 'when there is no current user' do
      it 'has adult checked' do
        expect(section).to have_checked_field('Adult actions')
      end
    end
  end

  ### TESTS START HERE ###

  before do
    # later we should simulate navigating here
    sign_in(user) if user
    visit school_recommendations_url(school)
  end

  it_behaves_like 'a page with breadcrumbs', ['Schools', 'School Name', 'Recommended activities and actions']

  it 'has the title' do
    expect(page).to have_content('Recommended activities and actions')
  end

  it 'has the intro' do
    expect(page).to have_content('Find your next energy saving activity to score points for your school,')
  end

  context 'with prompts', without_feature: :todos do
    context 'programme prompt' do
      let(:programme_type) { create(:programme_type_with_activity_types, bonus_score: 12) }
      let(:setup_data) { create(:programme, programme_type: programme_type, started_on: Time.zone.today, school: school) }

      it_behaves_like 'a complete programme prompt', with_programme: true
    end

    context 'join programme prompt' do
      let(:bonus_points) { 14 }
      let(:programme_type) { create(:programme_type_with_activity_types, title: 'Programme A', bonus_score: bonus_points) }

      context 'when one programme activity has been completed' do
        let(:activity_type) { programme_type.activity_types.first }
        let(:setup_data) { school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category, happened_on: Time.zone.now) }

        it_behaves_like 'a join programme prompt', programme: 'Programme A', task_count: 1
      end

      context 'when two programme activities have been completed' do
        let(:setup_data) do
          programme_type.activity_types.first(2).each do |activity_type|
            school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category, happened_on: Time.zone.now)
          end
        end

        it_behaves_like 'a join programme prompt', programme: 'Programme A', task_count: 2
      end

      context 'when all programme activities have been completed' do
        let(:setup_data) do
          programme_type.activity_types.each do |activity_type|
            school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category, happened_on: Time.zone.now)
          end
        end

        it_behaves_like 'a join programme prompt', programme: 'Programme A', completed: true, bonus_points: 14

        context 'when there are no bonus points' do
          let(:bonus_points) { 0 }

          it_behaves_like 'a join programme prompt', programme: 'Programme A', completed: true, bonus_points: 0
        end
      end
    end

    context 'audit prompt' do
      let(:setup_data) do
        SiteSettings.create!(audit_activities_bonus_points: 50)
        create(:audit, :with_activity_and_intervention_types, school: school)
      end

      it_behaves_like 'a rich audit prompt'
    end
  end

  context 'with prompts', with_feature: :todos do
    before do
      visit school_recommendations_url(school)
    end

    context 'programme prompt' do
      let(:programme_type) { create(:programme_type, :with_todos, bonus_score: 12) }
      let(:setup_data) { create(:programme, programme_type: programme_type, started_on: Time.zone.today, school: school) }

      it_behaves_like 'a complete programme prompt', with_programme: true
    end

    context 'join programme prompt' do
      let(:bonus_points) { 14 }
      let(:programme_type) { create(:programme_type, :with_todos, title: 'Programme A', bonus_score: bonus_points) }

      context 'when one programme activity has been completed' do
        let(:activity_type) { programme_type.activity_type_tasks.first }
        let(:setup_data) { school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category, happened_on: Time.zone.now) }

        it_behaves_like 'a join programme prompt', programme: 'Programme A', task_count: 1
      end

      context 'when two programme activities have been completed' do
        let(:setup_data) do
          programme_type.activity_type_tasks.first(2).each do |activity_type|
            school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category, happened_on: Time.zone.now)
          end
        end

        it_behaves_like 'a join programme prompt', programme: 'Programme A', task_count: 2
      end

      context 'when all programme tasks have been completed' do
        let(:setup_data) do
          programme_type.activity_type_tasks.each do |activity_type|
            school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category, happened_on: Time.zone.now)
          end
          programme_type.intervention_type_tasks.each do |intervention_type|
            school.observations.intervention.create!(intervention_type: intervention_type, at: Time.zone.now)
          end
        end

        it_behaves_like 'a join programme prompt', programme: 'Programme A', completed: true, bonus_points: 14

        context 'when there are no bonus points' do
          let(:bonus_points) { 0 }

          it_behaves_like 'a join programme prompt', programme: 'Programme A', completed: true, bonus_points: 0
        end
      end
    end

    context 'audit prompt' do
      let(:setup_data) do
        SiteSettings.create!(audit_activities_bonus_points: 50)
        create(:audit, :with_todos, school: school)
      end

      it_behaves_like 'a rich audit prompt'
    end
  end

  context 'based on your energy usage section' do
    let(:section) { find(:css, '#energy-usage') }
    let(:setup_data) do
      allow_any_instance_of(Recommendations::Actions).to receive(:based_on_energy_use).and_return(create_list(:intervention_type, 1))
      allow_any_instance_of(Recommendations::Activities).to receive(:based_on_energy_use).and_return(create_list(:activity_type, 1))
    end

    it 'has a title' do
      expect(section).to have_content('Based on your energy usage')
    end

    it 'has description' do
      expect(section).to have_content('These suggestions are based on our analysis of your energy usage data')
    end

    it_behaves_like 'a panel selector with scope'
  end

  context 'based on your recent activity section' do
    let(:section) { find(:css, '#recent-activity') }
    let(:setup_data) do
      allow_any_instance_of(Recommendations::Actions).to receive(:based_on_recent_activity).and_return(create_list(:intervention_type, 1))
      allow_any_instance_of(Recommendations::Activities).to receive(:based_on_recent_activity).and_return(create_list(:activity_type, 1))
    end

    it 'has a title' do
      expect(section).to have_content('Based on your recent activity')
    end

    it 'has description' do
      expect(section).to have_content('These suggestions are based on your most recently recorded activity')
    end

    it_behaves_like 'a panel selector with scope'
  end

  context 'more ideas section' do
    let(:section) { find(:css, '#more-ideas') }

    it 'has a title' do
      expect(section).to have_content('More ideas')
    end

    it 'has description' do
      expect(section).to have_content('Looking for more ideas? Explore some of these options')
    end

    it 'has a link to programmes' do
      expect(section).to have_link(href: '/programme_types')
    end

    it 'has a link to activities' do
      expect(section).to have_link(href: '/activity_categories')
    end

    it 'has a link to actions' do
      expect(section).to have_link(href: '/intervention_type_groups')
    end

    it 'has a link to schools advice page' do
      expect(section).to have_link(href: "/schools/#{school.slug}/advice")
    end

    it 'has a link to schools recent alerts' do
      expect(section).to have_link(href: "/schools/#{school.slug}/advice/alerts")
    end

    context 'when school is not data enabled' do
      let!(:school) { create :school, name: 'School Name', key_stages: [key_stage_1], data_enabled: false }

      it 'does not have advice or alerts links' do
        expect(section).not_to have_link(href: "/schools/#{school.slug}/advice")
        expect(section).not_to have_link(href: "/schools/#{school.slug}/advice/alerts")
      end
    end
  end
end
