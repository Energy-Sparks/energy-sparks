# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdultRemindersComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:id) { 'custom-id'}
  let(:classes) { 'extra-classes' }
  let(:user) { create(:admin) }
  let(:school) { create(:school) }

  let(:params) do
    {
      school: school,
      user: user,
      id: id,
      classes: classes
    }
  end

  describe '#prompt_for_bill?' do
    context 'with admin' do
      it { expect(component.prompt_for_bill?).to be(false) }
    end

    context 'with bill requested' do
      let(:school) { create(:school, bill_requested: true) }

      context 'with admin' do
        it { expect(component.prompt_for_bill?).to be(true) }
      end

      context 'with school admin' do
        let(:user) { create(:school_admin, school: school)}

        it { expect(component.prompt_for_bill?).to be(true) }
      end

      context 'with other' do
        let(:user) { create(:school_admin) }

        it { expect(component.prompt_for_bill?).to be(false) }
      end

      context 'with guest' do
        let(:user) { create(:guest) }

        it { expect(component.prompt_for_bill?).to be(false) }
      end
    end
  end

  describe '#prompt_for_training?' do
    context 'with admin' do
      it { expect(component.prompt_for_training?).to be(false) }
    end

    context 'when school is data enabled' do
      let!(:school) { create(:school, data_enabled: true) }

      context 'with school admin' do
        context 'when recently confirmed' do
          let!(:user) { create(:school_admin, confirmed_at: Time.zone.now, school: school)}

          it { expect(component.prompt_for_training?).to be(true) }
        end

        context 'when confirmed some time ago' do
          let!(:user) { create(:school_admin, confirmed_at: 1.year.ago, school: school)}

          it { expect(component.prompt_for_training?).to be(false) }
        end
      end

      context 'with other' do
        let!(:user) { create(:school_admin) }

        it { expect(component.prompt_for_training?).to be(false) }
      end

      context 'with guest' do
        let!(:user) { create(:guest) }

        it { expect(component.prompt_for_training?).to be(false) }
      end
    end

    context 'with other' do
      let!(:user) { create(:school_admin) }

      it { expect(component.prompt_for_training?).to be(false) }
    end

    context 'with guest' do
      let!(:user) { create(:guest) }

      it { expect(component.prompt_for_training?).to be(false) }
    end
  end

  describe '#prompt_for_contacts?' do
    before do
      SiteSettings.create!(message_for_no_contacts: true)
    end

    context 'with admin' do
      it { expect(component.prompt_for_contacts?).to be(true) }
    end

    context 'with contacts' do
      before do
        create(:contact_with_name_email_phone, school: school)
      end

      context 'with school admin' do
        let!(:user) { create(:school_admin, school: school)}

        it { expect(component.prompt_for_contacts?).to be(false) }
      end
    end

    context 'with school admin' do
      let!(:user) { create(:school_admin, school: school)}

      it { expect(component.prompt_for_contacts?).to be(true) }
    end

    context 'with other' do
      let!(:user) { create(:school_admin) }

      it { expect(component.prompt_for_contacts?).to be(false) }
    end

    context 'with guest' do
      let!(:user) { create(:guest) }

      it { expect(component.prompt_for_contacts?).to be(false) }
    end
  end

  describe '#prompt_for_pupils?' do
    before do
      SiteSettings.create!(message_for_no_pupil_accounts: true)
    end

    context 'with admin' do
      it { expect(component.prompt_for_pupils?).to be(true) }
    end

    context 'with pupil login' do
      before do
        create(:pupil, school: school)
      end

      context 'with school admin' do
        let!(:user) { create(:school_admin, school: school)}

        it { expect(component.prompt_for_pupils?).to be(false) }
      end
    end

    context 'with school admin' do
      let!(:user) { create(:school_admin, school: school)}

      it { expect(component.prompt_for_pupils?).to be(true) }
    end

    context 'with other' do
      let!(:user) { create(:school_admin) }

      it { expect(component.prompt_for_pupils?).to be(false) }
    end

    context 'with guest' do
      let!(:user) { create(:guest) }

      it { expect(component.prompt_for_pupils?).to be(false) }
    end
  end

  describe '#prompt_for_target?' do
    context 'with admin' do
      it { expect(component.send(:prompt_for_target?)).to be(true) }
    end

    context 'with school admin' do
      let!(:user) { create(:school_admin, school: school)}

      it { expect(component.send(:prompt_for_target?)).to be(true) }
    end

    context 'with other' do
      let!(:user) { create(:school_admin) }

      it { expect(component.send(:prompt_for_target?)).to be(false) }
    end

    context 'with guest' do
      let!(:user) { create(:guest) }

      it { expect(component.send(:prompt_for_target?)).to be(false) }
    end
  end

  describe '#prompt_to_review_target?' do
    context 'with no target' do
      context 'with admin' do
        it { expect(component.send(:prompt_to_review_target?)).to be_nil }
      end

      context 'with school admin' do
        let!(:user) { create(:school_admin, school: school)}

        it { expect(component.send(:prompt_to_review_target?)).to be_nil }
      end

      context 'with other' do
        let!(:user) { create(:school_admin) }

        it { expect(component.send(:prompt_to_review_target?)).to be(false) }
      end

      context 'with guest' do
        let!(:user) { create(:guest) }

        it { expect(component.send(:prompt_to_review_target?)).to be(false) }
      end
    end

    context 'with target needing review' do
      before do
        create(:school_target, school: school)
        service = instance_double(Targets::SchoolTargetService)
        allow(service).to receive(:prompt_to_review_target?).and_return(true)
        allow(Targets::SchoolTargetService).to receive(:new).and_return(service)
      end

      context 'with admin' do
        it { expect(component.send(:prompt_to_review_target?)).to be(true) }
      end

      context 'with school admin' do
        let!(:user) { create(:school_admin, school: school)}

        it { expect(component.send(:prompt_to_review_target?)).to be(true) }
      end

      context 'with other' do
        let!(:user) { create(:school_admin) }

        it { expect(component.send(:prompt_to_review_target?)).to be(false) }
      end

      context 'with guest' do
        let!(:user) { create(:guest) }

        it { expect(component.send(:prompt_to_review_target?)).to be(false) }
      end
    end
  end

  describe '#prompt_to_set_new_target?' do
    context 'with no target' do
      context 'with admin' do
        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end

      context 'with school admin' do
        let!(:user) { create(:school_admin, school: school)}

        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end

      context 'with other' do
        let!(:user) { create(:school_admin) }

        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end

      context 'with guest' do
        let!(:user) { create(:guest) }

        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end
    end

    context 'with current target' do
      before do
        create(:school_target, school: school)
      end

      context 'with admin' do
        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end

      context 'with school admin' do
        let!(:user) { create(:school_admin, school: school)}

        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end

      context 'with other' do
        let!(:user) { create(:school_admin) }

        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end

      context 'with guest' do
        let!(:user) { create(:guest) }

        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end
    end

    context 'with expired target' do
      before do
        create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
      end

      context 'with admin' do
        it { expect(component.send(:prompt_to_set_new_target?)).to be(true) }
      end

      context 'with school admin' do
        let!(:user) { create(:school_admin, school: school)}

        it { expect(component.send(:prompt_to_set_new_target?)).to be(true) }
      end

      context 'with other' do
        let!(:user) { create(:school_admin) }

        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end

      context 'with guest' do
        let!(:user) { create(:guest) }

        it { expect(component.send(:prompt_to_set_new_target?)).to be(false) }
      end
    end
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    before do
      SiteSettings.create!(message_for_no_pupil_accounts: true, message_for_no_contacts: true)
    end

    it { expect(html).to have_content(I18n.t('schools.prompts.programme.choose_a_new_programme_message')) }

    it {
      expect(html).to have_link(I18n.t('schools.prompts.programme.start_a_new_programme'),
                                   href: programme_types_path)
    }

    context 'when school has an active programme' do
      let!(:programme) { create(:programme, school: school) }

      it { expect(html).to have_content("You haven't yet completed") }

      it {
        expect(html).to have_link(I18n.t('common.labels.view_now'),
                                     href: programme_type_path(programme.programme_type))
      }

      it { expect(html).not_to have_selector('#new_programme') }
    end


    it { expect(html).to have_content(I18n.t('schools.show.setup_pupil_account')) }

    it {
      expect(html).to have_link(I18n.t('schools.show.create_pupil_account'),
                                   href: new_school_pupil_path(school))
    }

    it { expect(html).to have_content(I18n.t('schools.show.setup_alert_contacts')) }

    it {
      expect(html).to have_link(I18n.t('schools.show.add_alert_contacts'),
                                   href: school_contacts_path(school))
    }

    it { expect(html).to have_content(I18n.t('schools.show.set_targets')) }

    it {
      expect(html).to have_link(I18n.t('schools.show.set_target'),
                                   href: school_school_targets_path(school))
    }

    context 'when bill requested' do
      let(:school) { create(:school, bill_requested: true) }

      it { expect(html).to have_content(I18n.t('schools.show.set_targets')) }

      it {
        expect(html).to have_link(I18n.t('schools.show.upload_energy_bill'),
                                     href: school_consent_documents_path(school))
      }
    end

    context 'when user should be prompted for training' do
      let!(:user) { create(:school_admin, confirmed_at: Time.zone.now, school: school)}

      it { expect(html).to have_content(I18n.t('schools.show.online_training_signup')) }

      it {
        expect(html).to have_link(I18n.t('schools.show.find_training'),
                                     href: training_path)
      }
    end

    context 'when there has been an audit with unfinished tasks' do
      let!(:audit) { create(:audit, :with_todos, school: school) }

      it {
        expect(html).to have_link(I18n.t('common.labels.view_now'),
                                     href: school_audit_path(school, audit))
      }
    end

    context 'with target needing review' do
      before do
        create(:school_target, school: school)
        service = instance_double(Targets::SchoolTargetService)
        allow(service).to receive(:prompt_to_review_target?).and_return(true)
        allow(Targets::SchoolTargetService).to receive(:new).and_return(service)
      end

      it { expect(html).to have_content(I18n.t('schools.show.revisit_targets')) }

      it {
        expect(html).to have_link(I18n.t('schools.show.review_target'),
                                     href: school_school_targets_path(school))
      }
    end

    context 'with expired target' do
      before do
        create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
      end

      it { expect(html).to have_content('Your school set a target to reduce its energy usage') }

      it {
        expect(html).to have_link(I18n.t('schools.show.review_progress'),
                                     href: school_school_targets_path(school))
      }
    end

    it 'displays the default prompts' do
      within('#custom-id') do
        expect(html).to have_css('#add_pupils')
        expect(html).to have_css('#add_contacts')
        expect(html).to have_css('#set_target')
      end
    end
  end
end
