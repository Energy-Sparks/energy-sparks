# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManageSchoolNavigationComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:school) { create_active_school }
  let(:current_user) { create(:school_admin, school: school) }

  let(:params) do
    { school: school, current_user: current_user, classes: 'extra-classes' }
  end

  shared_examples 'a correctly populated settings section' do
    it 'has the correct links' do
      within('#settings') do
        expect(html).to have_link(I18n.t('manage_school_menu.edit_school_times'), href: edit_school_times_path(school))
        expect(html).to have_link(I18n.t('manage_school_menu.your_school_estate'), href: edit_school_your_school_estate_path(school))
        expect(html).to have_link(I18n.t('manage_school_menu.school_calendar'), href: calendar_path(school))
        expect(html).to have_link(I18n.t('manage_school_menu.manage_users'), href: school_users_path(school))
        expect(html).to have_link(I18n.t('manage_school_menu.alert_contacts'), href: school_contacts_path(school))
      end
    end
  end

  shared_examples 'a correctly populated users section' do
    it 'has the correct links' do
      within('#users') do
        expect(html).to have_link(I18n.t('manage_school_menu.manage_users'), href: school_users_path(school))
        expect(html).to have_link(I18n.t('manage_school_menu.manage_alert_contacts'), href: school_contacts_path(school))
      end
    end
  end

  shared_examples 'a correctly populated metering section' do |admin: false|
    it 'has the correct links' do
      within('#metering') do
        expect(html).to have_link(I18n.t('manage_school_menu.manage_meters'),
                       href: school_meters_path(school))
        expect(html).to have_link(I18n.t('manage_school_menu.manage_tariffs'),
                       href: school_energy_tariffs_path(school))
        expect(html).to have_link(I18n.t('manage_school_menu.school_downloads'),
                      href: school_downloads_path(school))
      end
    end

    it 'does not have admin links', unless: admin do
      expect(html).not_to have_link(I18n.t('schools.meters.index.manage_solar_api_feeds'),
                    href: school_solar_feeds_configuration_index_path(school))
      expect(html).not_to have_link(I18n.t('schools.meters.index.meter_reviews'), href: admin_school_meter_reviews_path(school))
    end

    it 'has admin links', if: admin do
      expect(html).to have_link(I18n.t('schools.meters.index.manage_solar_api_feeds'),
                    href: school_solar_feeds_configuration_index_path(school))
      expect(html).to have_link(I18n.t('schools.meters.index.meter_reviews'), href: admin_school_meter_reviews_path(school))
    end
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    context 'with school admin' do
      it 'has the expected sections' do
        expect(html).to have_content(I18n.t('components.manage_school_navigation.settings'))
        expect(html).to have_content(I18n.t('components.manage_school_navigation.users'))
        expect(html).to have_content(I18n.t('components.manage_school_navigation.metering'))
        expect(html).not_to have_content(I18n.t('components.manage_school_navigation.admin'))
      end

      it_behaves_like 'a correctly populated settings section'
      it_behaves_like 'a correctly populated users section'
      it_behaves_like 'a correctly populated metering section'
    end

    context 'with admin' do
      let(:current_user) { create(:admin) }

      it 'has the expected sections' do
        expect(html).to have_content(I18n.t('components.manage_school_navigation.settings'))
        expect(html).to have_content(I18n.t('components.manage_school_navigation.users'))
        expect(html).to have_content(I18n.t('components.manage_school_navigation.metering'))
        expect(html).to have_content(I18n.t('components.manage_school_navigation.admin'))
      end

      it_behaves_like 'a correctly populated settings section'
      it_behaves_like 'a correctly populated users section'
      it_behaves_like 'a correctly populated metering section', admin: true

      it 'has correct admin section' do
        within('#admin') do
          expect(html).to have_link(I18n.t('manage_school_menu.school_configuration'),
                         href: edit_school_configuration_path(school))
          expect(html).to have_link(I18n.t('manage_school_menu.meter_attributes'),
                         href: admin_school_meter_attributes_path(school))
          expect(html).to have_link(I18n.t('manage_school_menu.manage_audits'),
                         href: school_audits_path(school))
          expect(html).to have_link(I18n.t('manage_school_menu.manage_partners'),
                        href: admin_school_partners_path(school))
          expect(html).to have_link(I18n.t('manage_school_menu.manage_issues'),
                         href: admin_school_issues_path(school))
          expect(html).to have_link(I18n.t('manage_school_menu.batch_reports'),
                         href: school_reports_path(school))
          expect(html).to have_link(I18n.t('manage_school_menu.remove_school'),
                         href: removal_admin_school_path(school))
        end
      end

      context 'when showing expert analysis' do
        context 'when school has gas' do
          let(:school) { create(:school, :with_fuel_configuration) }

          it 'links to the analysis' do
            within('#admin') do
              expect(html).to have_link(I18n.t('manage_school_menu.expert_analysis'),
                             href: admin_school_analysis_path(school))
            end
          end
        end

        context 'when school does not have gas' do
          let(:school) { create(:school, :with_fuel_configuration, has_gas: false) }

          it 'links to the analysis' do
            within('#admin') do
              expect(html).not_to have_link(I18n.t('manage_school_menu.expert_analysis'),
                             href: admin_school_analysis_path(school))
            end
          end
        end
      end
    end
  end
end
