# frozen_string_literal: true

require 'rails_helper'

shared_examples 'when show_actions is false' do
  let(:show_actions) { false }

  it { expect(html).not_to have_link('Edit') }
  it { expect(html).not_to have_link('Delete') }
end

RSpec.describe ObservationComponent, type: :component, include_url_helpers: true do
  let(:observation) { }

  let(:show_actions) { true }
  let(:style) { :full }

  let(:all_params) { { observation: observation, show_actions: show_actions, style: style } }
  let(:params) { all_params }
  let(:current_user) { create(:admin) }

  before do
    # This allows us to set what the current user is during rendering
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  let(:html) do
    with_controller_class ApplicationController do
      render_inline(ObservationComponent.new(**params))
    end
  end

  context 'with activity observation' do
    let(:observation) { create(:observation, :activity) }

    it { expect(html).to have_css('i.fa-clipboard-check') }
    it { expect(html).to have_content("Completed an activity: #{observation.activity.display_name}") }
    it { expect(html).to have_link(observation.activity.display_name, href: school_activity_path(observation.school, observation.activity)) }

    context 'when show_actions is true' do
      let(:show_actions) { true }

      it { expect(html).to have_link('Edit', href: edit_school_activity_path(observation.school, observation.activity)) }
      it { expect(html).to have_link('Delete', href: school_activity_path(observation.school, observation.activity)) }
    end

    it_behaves_like 'when show_actions is false'

    context 'when style is compact' do
      let(:style) { :compact }

      it { expect(html).to have_css('i.fa-clipboard-check') }
      it { expect(html).to have_content("scored #{observation.activity.activity_type.score} points after they recorded \"#{observation.activity.display_name}\"") }
      it { expect(html).to have_link(observation.activity.display_name, href: school_activity_path(observation.school, observation.activity)) }
    end

    context 'when style is description' do
      let(:style) { :description }

      it { expect(html).to have_css('i.fa-clipboard-check') }
      it { expect(html).to have_link(observation.activity.display_name, href: school_activity_path(observation.school, observation.activity)) }
    end
  end

  context 'with audit observation' do
    let(:observation) { create(:observation, :audit) }

    it { expect(html).to have_css('i.fa-clipboard-check') }
    it { expect(html).to have_content('Received an energy audit') }
    it { expect(html).to have_link(observation.observable.title, href: school_audit_path(observation.school, observation.observable)) }

    context 'when show_actions is true' do
      let(:show_actions) { true }

      it { expect(html).to have_link('Edit', href: edit_school_audit_path(observation.school, observation.observable)) }
      it { expect(html).to have_link('Delete', href: school_audit_path(observation.school, observation.observable)) }
    end

    it_behaves_like 'when show_actions is false'

    context 'when style is compact' do
      let(:style) { :compact }

      it { expect(html).to have_css('i.fa-clipboard-check') }
      it { expect(html).to have_content("#{observation.school.name} ") }
      it { expect(html).to have_link('received an energy audit', href: school_audit_path(observation.school, observation.observable)) }
    end

    context 'when style is description' do
      let(:style) { :description }

      it { expect(html).to have_css('i.fa-clipboard-check') }
      it { expect(html).to have_link('Received an energy audit', href: school_audit_path(observation.school, observation.observable)) }
    end
  end

  context 'with audit_activities_completed observation' do
    let(:observation) { create(:observation, :audit_activities_completed) }

    it { expect(html).to have_css('i.fa-clipboard-check') }
    it { expect(html).to have_content('Completed all audit activities:') }
    it { expect(html).to have_link(observation.observable.title, href: school_audit_path(observation.school, observation.observable)) }

    context 'when show_actions is true' do
      let(:show_actions) { true }

      it { expect(html).not_to have_link('Edit') }
      it { expect(html).not_to have_link('Delete') }
    end

    it_behaves_like 'when show_actions is false'

    context 'when style is compact' do
      let(:style) { :compact }

      it { expect(html).to have_css('i.fa-clipboard-check') }
      it { expect(html).to have_content("#{observation.school.name} completed all energy audit activities") }
    end

    context 'when style is description' do
      let(:style) { :description }

      it { expect(html).to have_css('i.fa-clipboard-check') }
      it { expect(html).to have_content('Completed all energy audit activities') }
    end
  end

  context 'with intervention observation' do
    let(:observation) { create(:observation, :intervention) }

    it { expect(html).to have_css("i.fa-#{observation.intervention_type.intervention_type_group.icon}") }
    it { expect(html).to have_link(observation.intervention_type.name, href: school_intervention_path(observation.school, observation)) }

    context 'when show_actions is true' do
      let(:show_actions) { true }

      it { expect(html).to have_link('Edit', href: edit_school_intervention_path(observation.school, observation)) }
      it { expect(html).to have_link('Delete', href: school_intervention_path(observation.school, observation)) }
    end

    it_behaves_like 'when show_actions is false'

    context 'when style is compact' do
      let(:style) { :compact }

      it { expect(html).to have_css("i.fa-#{observation.intervention_type.intervention_type_group.icon}") }
      it { expect(html).to have_content("scored #{observation.intervention_type.score} points after they recorded \"#{observation.intervention_type.name}\"") }
      it { expect(html).to have_link(observation.school.name, href: school_path(observation.school)) }
      it { expect(html).to have_link(observation.intervention_type.name, href: school_intervention_path(observation.school, observation)) }
    end

    context 'when style is description' do
      let(:style) { :description }

      it { expect(html).to have_css("i.fa-#{observation.intervention_type.intervention_type_group.icon}") }
      it { expect(html).to have_link(observation.intervention_type.name, href: school_intervention_path(observation.school, observation)) }
    end
  end

  context 'with programme observation' do
    let(:observation) { create(:observation, :programme) }

    it { expect(html).to have_css('i.fa-clipboard-check') }
    it { expect(html).to have_content('Completed a programme: ') }
    it { expect(html).to have_link(observation.observable.programme_type.title, href: programme_type_path(observation.observable.programme_type)) }

    context 'when show_actions is true' do
      let(:show_actions) { true }

      it { expect(html).not_to have_link('Edit') }
      it { expect(html).not_to have_link('Delete') }
    end

    it_behaves_like 'when show_actions is false'

    context 'when style is compact' do
      let(:style) { :compact }

      it { expect(html).to have_css('i.fa-clipboard-check') }
      it { expect(html).to have_content("#{observation.school.name} completed a programme") }
    end

    context 'when style is description' do
      let(:style) { :description }

      it { expect(html).to have_css('i.fa-clipboard-check') }
      it { expect(html).to have_content('Completed a programme') }
    end
  end

  context 'with school target observation' do
    let(:observation) { create(:observation, :school_target) }

    it { expect(html).to have_css('i.fa-tachometer-alt') }
    it { expect(html).to have_link('Started working towards an energy saving target', href: school_school_target_path(observation.school, observation.observable)) }

    context 'when show_actions is true' do
      let(:show_actions) { true }

      it { expect(html).to have_link('Edit', href: edit_school_school_target_path(observation.school, observation.observable)) }
      it { expect(html).to have_link('Delete', href: school_school_target_path(observation.school, observation.observable)) }
    end

    it_behaves_like 'when show_actions is false'

    context 'when style is compact' do
      let(:style) { :compact }

      it { expect(html).to have_css('i.fa-tachometer-alt') }
      it { expect(html).to have_content("#{observation.school.name} started working towards their energy saving target") }
      it { expect(html).to have_link('energy saving target', href: school_school_target_path(observation.school, observation.observable)) }
    end

    context 'when style is description' do
      let(:style) { :description }

      it { expect(html).to have_css('i.fa-tachometer-alt') }
      it { expect(html).to have_content('Started working towards their energy saving target') }
      it { expect(html).to have_link('energy saving target', href: school_school_target_path(observation.school, observation.observable)) }
    end
  end

  context 'with temperature observation' do
    let(:observation) { create(:observation, :temperature) }

    it { expect(html).to have_css('i.fa-temperature-high') }
    it { expect(html).to have_content('Recorded indoor temperatures in: ') }
    it { expect(html).to have_link('', href: school_temperature_observations_path(observation.school)) }

    context 'when show_actions is true' do
      let(:show_actions) { true }

      it { expect(html).not_to have_link('Edit') }
      it { expect(html).to have_link('Delete', href: school_temperature_observation_path(observation.school, observation)) }
    end

    it_behaves_like 'when show_actions is false'

    context 'when style is compact' do
      let(:style) { :compact }

      it { expect(html).to have_css('i.fa-temperature-high') }
      it { expect(html).to have_content("#{observation.school.name} scored 5 points by recording indoor temperatures") }
    end

    context 'when style is description' do
      let(:style) { :description }

      it { expect(html).to have_css('i.fa-temperature-high') }
      it { expect(html).to have_content('Recorded indoor temperatures') }
    end
  end

  context 'with transport survey observation' do
    let(:observation) { create(:observation, :transport_survey) }

    it { expect(html).to have_css('i.fa-car') }
    it { expect(html).to have_link('Recorded 0 transport survey responses', href: school_transport_survey_path(observation.school, observation.observable)) }

    context 'when show_actions is true' do
      let(:show_actions) { true }

      it { expect(html).to have_link('Edit', href: edit_school_transport_survey_path(observation.school, observation.observable)) }
      it { expect(html).to have_link('Delete', href: school_transport_survey_path(observation.school, observation.observable)) }
    end

    it_behaves_like 'when show_actions is false'

    context 'when style is compact' do
      let(:style) { :compact }

      it { expect(html).to have_css('i.fa-car') }
      it { expect(html).to have_content("#{observation.school.name} started a transport survey") }
    end

    context 'when style is description' do
      let(:style) { :description }

      it { expect(html).to have_css('i.fa-car') }
      it { expect(html).to have_content('Started a transport survey') }
    end
  end
end
