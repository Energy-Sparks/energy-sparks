# frozen_string_literal: true

require "rails_helper"

RSpec.describe TimelineComponent, type: :component, include_url_helpers: true do
  let(:observation) { create(:observation, :activity) }
  let(:observations) { [observation] }
  let(:show_actions) { true }
  let(:all_params) { { observations: observations, classes: 'my-class', id: 'my-id', show_actions: show_actions } }
  let(:params) { all_params }
  let(:current_user) { create(:admin) }

  before do
    # This allows us to set what the current user is during rendering
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  let(:html) do
    with_controller_class ApplicationController do
      render_inline(TimelineComponent.new(**params))
    end
  end

  context "with all params" do
    it { expect(html).to have_selector("div.timeline-component") }

    it "adds specified classes" do
      expect(html).to have_css('div.timeline-component.my-class')
    end

    it "adds specified id" do
      expect(html).to have_css('div.timeline-component#my-id')
    end
  end

  shared_examples "when show_actions is false" do
    let(:show_actions) { false }

    it { expect(html).not_to have_link("Edit") }
    it { expect(html).not_to have_link("Delete") }
  end

  context "with activity observation" do
    let(:observation) { create(:observation, :activity) }

    it { expect(html).to have_css('i.fa-clipboard-check') }
    it { expect(html).to have_content("Completed an activity: #{observation.activity.display_name}") }
    it { expect(html).to have_link(observation.activity.display_name, href: school_activity_path(observation.school, observation.activity)) }

    context "when show_actions is true" do
      let(:show_actions) { true }

      it { expect(html).to have_link("Edit", href: edit_school_activity_path(observation.school, observation.activity)) }
      it { expect(html).to have_link("Delete", href: school_activity_path(observation.school, observation.activity)) }
    end

    it_behaves_like "when show_actions is false"
  end

  context "with audit observation" do
    let(:observation) { create(:observation, :audit) }

    it { expect(html).to have_css('i.fa-clipboard-check') }
    it { expect(html).to have_content("Received an energy audit") }
    it { expect(html).to have_link(observation.audit.title, href: school_audit_path(observation.school, observation.audit)) }

    context "when show_actions is true" do
      let(:show_actions) { true }

      it { expect(html).to have_link("Edit", href: edit_school_audit_path(observation.school, observation.audit)) }
      it { expect(html).to have_link("Delete", href: school_audit_path(observation.school, observation.audit)) }
    end

    it_behaves_like "when show_actions is false"
  end

  context "with audit_activities_completed observation" do
    let(:observation) { create(:observation, :audit_activities_completed) }

    it { expect(html).to have_css('i.fa-clipboard-check') }
    it { expect(html).to have_content("Completed all audit activities:") }
    it { expect(html).to have_link(observation.audit.title, href: school_audit_path(observation.school, observation.audit)) }

    context "when show_actions is true" do
      let(:show_actions) { true }

      it { expect(html).not_to have_link("Edit") }
      it { expect(html).not_to have_link("Delete") }
    end

    it_behaves_like "when show_actions is false"
  end

  context "with intervention observation" do
    let(:observation) { create(:observation, :intervention) }

    it { expect(html).to have_css("i.fa-#{observation.intervention_type.intervention_type_group.icon}") }
    it { expect(html).to have_content("Completed an action: ") } # I did change this to add this prefix!
    it { expect(html).to have_link(observation.intervention_type.name, href: school_intervention_path(observation.school, observation)) }

    context "when show_actions is true" do
      let(:show_actions) { true }

      it { expect(html).to have_link("Edit", href: edit_school_intervention_path(observation.school, observation)) }
      it { expect(html).to have_link("Delete", href: school_intervention_path(observation.school, observation)) }
    end

    it_behaves_like "when show_actions is false"
  end

  context "with programme observation" do
    let(:observation) { create(:observation, :programme) }

    it { expect(html).to have_css("i.fa-clipboard-check") }
    it { expect(html).to have_content("Completed a programme: ") }
    it { expect(html).to have_link(observation.observable.programme_type.title, href: programme_type_path(observation.observable.programme_type)) }

    context "when show_actions is true" do
      let(:show_actions) { true }

      it { expect(html).not_to have_link("Edit") }
      it { expect(html).not_to have_link("Delete") }
    end

    it_behaves_like "when show_actions is false"
  end

  context "with school target observation" do
    let(:observation) { create(:observation, :school_target) }

    it { expect(html).to have_css('i.fa-tachometer-alt') }
    it { expect(html).to have_link("Started working towards an energy saving target", href: school_school_target_path(observation.school, observation.school_target)) }

    context "when show_actions is true" do
      let(:show_actions) { true }

      it { expect(html).to have_link("Edit", href: edit_school_school_target_path(observation.school, observation.school_target)) }
      it { expect(html).to have_link("Delete", href: school_school_target_path(observation.school, observation.school_target)) }
    end

    it_behaves_like "when show_actions is false"
  end

  context "with temperature observation" do
    let(:observation) { create(:observation, :temperature) }

    it { expect(html).to have_css('i.fa-temperature-high') }
    it { expect(html).to have_content("Recorded temperatures in: ") }
    it { expect(html).to have_link("", href: school_temperature_observations_path(observation.school)) }

    context "when show_actions is true" do
      let(:show_actions) { true }

      it { expect(html).not_to have_link("Edit") }
      it { expect(html).to have_link("Delete", href: school_temperature_observation_path(observation.school, observation)) }
    end

    it_behaves_like "when show_actions is false"
  end

  context "with transport survey observation" do
    let(:observation) { create(:observation, :transport_survey) }

    it { expect(html).to have_css('i.fa-car') }
    it { expect(html).to have_link("Recorded 0 transport survey responses", href: school_transport_survey_path(observation.school, observation.observable)) }

    context "when show_actions is true" do
      let(:show_actions) { true }

      it { expect(html).to have_link("Edit", href: edit_school_transport_survey_path(observation.school, observation.observable)) }
      it { expect(html).to have_link("Delete", href: school_transport_survey_path(observation.school, observation.observable)) }
    end

    it_behaves_like "when show_actions is false"
  end
end
