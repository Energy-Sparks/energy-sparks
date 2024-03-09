# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComparisonTableComponent, type: :component, include_url_helpers: true do
  subject(:html) { render_inline(described_class.new(**params)) }

  # need to use key present in the routes
  let(:report) { create(:report, key: :baseload_per_pupil) }
  let(:advice_page) { nil }
  let(:advice_page_tab) { :insights }
  let(:table_name) { 'table' }
  let(:headers) { ['Col 1', 'Col 2'] }
  let(:colgroups) { [] }

  let(:params) do
    {
      report: report,
      advice_page: advice_page,
      table_name: table_name,
      index_params: {},
      headers: headers,
      colgroups: colgroups,
      advice_page_tab: advice_page_tab
    }
  end

  it 'renders a download link' do
    expect(html).to have_link(I18n.t('school_groups.download_as_csv'))
  end

  it 'inserts the table correctly' do
    expect(html).to have_css('table.advice-table')
    expect(html).to have_css('table.table-sorted')
    expect(html).to have_css('table thead.sticky-heading')
    expect(html).to have_css("##{report.key}-#{table_name}")
  end

  it 'inserts the headers' do
    headers.each do |header|
      expect(html).to have_selector('th', text: header)
    end
  end

  context 'with column groups' do
    let(:colgroups) do
      [{ label: '', colspan: 1 }, { label: 'Group 1', colspan: 2 }]
    end

    it 'adds the column groups' do
      colgroups.each do |group|
        expect(html).to have_selector("th[colspan=#{group[:colspan]}]", text: group[:label])
      end
    end
  end

  context 'with footer' do
    let(:footer) { 'This is the footer' }

    subject(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_footer do
          footer
        end
      end
    end

    it 'adds the footer' do
      within('table tfoot') do
        expect(html).to have_content(footer)
      end
    end
  end

  context 'when rendering rows' do
    context 'with school' do
      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_school school: school
          end
        end
      end

      let(:school) { create(:school) }

      it 'renders a link to advice page index' do
        expect(html).to have_link(school.name, href: school_advice_path(school))
      end

      context 'with advice page provided' do
        let(:advice_page) { create(:advice_page, key: :baseload) }

        it 'adds link to school advice page' do
          expect(html).to have_link(school.name, href: insights_school_advice_baseload_path(school))
        end

        context 'when tab is specified' do
          let(:advice_page_tab) { :analysis }

          it 'links to the tab' do
            expect(html).to have_link(school.name, href: analysis_school_advice_baseload_path(school))
          end
        end
      end
    end

    context 'with reference' do
      let(:reference) { 'This is the reference' }

      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_reference do
              reference
            end
          end
        end
      end

      it 'adds the reference' do
        expect(html).to have_content(reference)
      end
    end

    context 'with var as a block' do
      let(:var) { 'Data' }

      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_var do
              var
            end
          end
        end
      end

      it 'adds the variable' do
        expect(html).to have_content(var)
      end

      it 'adds the default classes' do
        expect(html).to have_css('td.text-right')
      end

      context 'when adding classes' do
        subject(:html) do
          render_inline(described_class.new(**params)) do |c|
            c.with_row do |r|
              r.with_var classes: 'text-left' do
                'Test'
              end
            end
          end
        end

        it 'adds the classes' do
          expect(html).to have_css('td.text-left')
        end
      end
    end

    context 'with var to be formatted' do
      let(:value) { 100 }

      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_var val: value, unit: :£
          end
        end
      end

      it 'adds the formatted value' do
        expect(html).to have_content('£100')
      end
    end

    context 'with var to be formatted as a change' do
      let(:value) { 0.5 }

      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_var val: value, unit: :relative_percent_0dp, change: true
          end
        end
      end

      it 'adds the formatted value' do
        expect(html).to have_content('+50%')
        expect(html).to have_css('i.fa-arrow-circle-up')
      end
    end
  end
end
