# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnergySummaryTableComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let!(:help_page) { create(:help_page, feature: :management_summary_overview, published: true) }

  let(:school) { create(:school) }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:user) { create(:school_admin, school: school) }
  let(:params) do
    {
      school: school,
      id: id,
      classes: classes,
      user: user
    }
  end

  let(:html) { render_inline(component) }

  let(:management_data) do
    Tables::SummaryTableData.new({
      electricity: {
        year: { kwh: 1000, £: 2000, co2: 500, savings_£: 330, :percent_change => 0.11050 },
        workweek: { kwh: 100, £: 200, co2: 50, savings_£: 33, :percent_change => -0.0923132131 }
      }
    })
  end

  before do
    double = instance_double(Schools::ManagementTableService, management_data: management_data)
    allow(Schools::ManagementTableService).to receive(:new).and_return(double)
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  context 'when school is data enabled' do
    it 'renders the table title' do
      expect(html).to have_content(I18n.t('schools.show.summary_of_recent_energy_usage'))
    end

    it 'renders the table' do
      expect(html).to have_selector(:table_row, [
                                      '', # no fuel type here as on previous row
                                      I18n.t('classes.tables.summary_table_data.last_year'),
                                      '1,000',
                                      '500',
                                      '£2,000',
                                      '£330',
                                      '+11%'
                                    ])

      expect(html).to have_selector(:table_row, [
                                      'Electricity',
                                      I18n.t('classes.tables.summary_table_data.last_week'),
                                      '100',
                                      '50',
                                      '£200',
                                      '£33',
                                      '-9.2%'
                                    ])
    end

    it 'renders the table footer' do
      expect(html).to have_content('More information')
      expect(html).to have_link(href: help_path(help_page))
    end

    context 'when show savings disabled' do
      let(:params) do
        {
          school: school,
          id: id,
          classes: classes,
          user: user,
          show_savings: false
        }
      end

      it 'does not show the savings' do
        expect(html).to have_selector(:table_row, [
                                        '', # no fuel type here as on previous row
                                        I18n.t('classes.tables.summary_table_data.last_year'),
                                        '1,000',
                                        '500',
                                        '£2,000',
                                        '+11%'
                                      ])

        expect(html).to have_selector(:table_row, [
                                        'Electricity',
                                        I18n.t('classes.tables.summary_table_data.last_week'),
                                        '100',
                                        '50',
                                        '£200',
                                        '-9.2%'
                                      ])
      end
    end

    context 'when title disabled' do
      let(:params) do
        {
          school: school,
          id: id,
          classes: classes,
          user: user,
          show_title: false
        }
      end

      it 'does not show the title' do
        expect(html).not_to have_content(I18n.t('schools.show.summary_of_recent_energy_usage'))
      end
    end
  end

  context 'with custom footer' do
    let(:html) do
      component do |c|
        c.with_footer do
          'My custom footer'
        end
      end
    end

    it 'renders the custom footer' do
      expect(html).not_to have_content('More information')
      expect(html).not_to have_content('My custom footer')
    end
  end

  context 'when school is not data enabled' do
    let(:school) { create(:school, data_enabled: false) }

    it 'does not render' do
      expect(html).not_to have_css('#custom-id')
    end

    context 'with an admin' do
      let(:user) { create(:admin) }

      it 'does render' do
        expect(html).to have_css('#custom-id')
      end
    end
  end
end