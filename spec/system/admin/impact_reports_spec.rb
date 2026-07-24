# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin impact report configuration' do
  before do
    Flipper.enable(:impact_reporting)
  end

  let!(:admin) { create(:admin) }
  let!(:school_group) { create(:school_group, :with_active_schools, count: 2) }
  let!(:other_school_group) { create(:school_group, :diocese) }
  let(:school) { school_group.assigned_schools.first }
  let!(:run) { create(:impact_report_run, :with_metrics, school_group:) }

  describe 'when not logged in' do
    context 'when visiting the index' do
      before do
        visit admin_impact_reports_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_text('You need to sign in or sign up before continuing.')
      end
    end

    context 'when editing a configuration' do
      before do
        visit edit_school_group_impact_configuration_path(school_group)
      end

      it 'does not authorise viewing' do
        expect(page).to have_text('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in as a non admin user' do
    let(:staff) { create(:staff) }

    before { sign_in(staff) }

    context 'when visiting the index' do
      before do
        visit admin_impact_reports_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_text('You are not authorized to view that page.')
      end
    end

    context 'when editing a configuration' do
      before do
        visit edit_school_group_impact_configuration_path(school_group)
      end

      it 'does not authorise viewing' do
        expect(page).to have_text('You are not authorized to view that page.')
      end
    end
  end

  # rubocop:disable RSpec/NestedGroups

  describe 'when logged in as admin' do
    before { sign_in(admin) }

    context 'when viewing the index' do
      before do
        create(:case_study, organisation: school_group)
        visit admin_impact_reports_path
      end

      it 'lists the organisation school group' do
        expect(page).to have_link(school_group.name)
      end

      it 'does not list the non-organisation school group' do
        expect(page).to have_no_link(other_school_group.name)
      end

      it 'shows report visibility as off' do
        within('tr', text: school_group.name) do
          expect(page).to have_css('td:nth-child(1) i.fa-times-circle')
        end
      end

      it 'shows report enough data as on' do
        within('tr', text: school_group.name) do
          expect(page).to have_css('td:nth-child(2) i.fa-check-circle')
        end
      end

      it 'shows case studies as on' do
        within('tr', text: school_group.name) do
          expect(page).to have_css('td:nth-child(5) i.fa-check-circle')
        end
      end

      it 'shows energy efficiency section as visible by default' do
        within('tr', text: school_group.name) do
          expect(page).to have_css('td:nth-child(6) i.fa-check-circle')
        end
      end

      it 'shows engagement section as visible by default' do
        within('tr', text: school_group.name) do
          expect(page).to have_css('td:nth-child(8) i.fa-check-circle')
        end
      end

      it 'has an edit link' do
        expect(page).to have_link('Edit')
      end
    end

    context 'when editing page' do
      before do
        visit edit_school_group_impact_configuration_path(school_group)
      end

      it { expect(page).to have_link('View report', href: school_group_impact_index_path(school_group)) }
      it { expect(page).to have_link('All reports', href: admin_impact_reports_path) }

      context 'when turning sections off' do
        before do
          uncheck 'impact_report_configuration_show_energy_efficiency'
          uncheck 'impact_report_configuration_show_engagement'
          click_on 'Save', match: :first
        end

        it 'updates the configuration' do
          expect(page).to have_text('Configuration was successfully updated.')
        end

        context 'when visiting the report' do
          before do
            visit school_group_impact_index_path(school_group)
          end

          it 'hides energy efficiency section on report' do
            expect(page).to have_no_css('#energy-efficiency')
          end

          it 'hides engagement section on report' do
            expect(page).to have_no_css('#engagement')
          end

          it 'shows overview and potential savings sections' do
            expect(page).to have_text('Overview')
            expect(page).to have_text('Potential savings')
          end
        end
      end

      context 'when adding a Energy efficiency featured school' do
        before do
          select school.name, from: 'impact_report_configuration_energy_efficiency_school_id'
          fill_in :impact_report_configuration_energy_efficiency_note, with: 'Note about energy efficiency'
          attach_file 'impact_report_configuration_energy_efficiency_image',
                      Rails.root.join('spec/fixtures/images/boiler.jpg')
          click_on 'Save', match: :first
        end

        context 'when visiting the report' do
          before do
            visit school_group_impact_index_path(school_group)
          end

          it 'shows feature' do
            expect(page).to have_text('Note about energy efficiency')
            expect(page).to have_css("img[src*='boiler.jpg']")
            expect(page).to have_link('View dashboard', href: school_path(school))
          end
        end
      end

      context 'when overriding default engaged school' do
        before do
          select school.name, from: 'impact_report_configuration_engagement_school_id'
          fill_in :impact_report_configuration_engagement_note, with: 'Note about engaged school'
          attach_file 'impact_report_configuration_engagement_image', Rails.root.join('spec/fixtures/images/laptop.jpg')
          click_on 'Save', match: :first
        end

        context 'when visiting the report' do
          before do
            visit school_group_impact_index_path(school_group)
          end

          it 'shows feauture' do
            expect(page).to have_text('Featured school')
            expect(page).to have_text('Note about engaged school')
            expect(page).to have_css("img[src*='laptop.jpg']")
            expect(page).to have_link('View dashboard', href: school_path(school))
          end
        end
      end

      context 'when report is made not visible' do
        before do
          uncheck 'Report visible'
          click_on 'Save', match: :first
        end

        context 'when visiting the report as an admin' do
          before do
            visit school_group_impact_index_path(school_group)
          end

          it 'still shows the report to admin users' do
            expect(page).to have_text('Overview')
            expect(page).to have_text('Potential savings')
          end
        end

        context 'when visiting the report as a non-admin user' do
          before do
            sign_out(admin)
            visit school_group_impact_index_path(school_group)
          end

          it 'does not show the report' do
            expect(page).to have_text('This feature is not available')
          end
        end

        context 'when there are not enough visible schools' do
          before do
            run.update!(visible_schools: 1)
            visit school_group_impact_index_path(school_group.reload)
          end

          it 'does not show the report' do
            expect(page).to have_text('Not enough data')
          end
        end
      end
    end
  end

  # rubocop:enable RSpec/NestedGroups
end
