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

  context 'with notes' do
    let(:note_1) { 'This is note 1' }
    let(:note_2) { 'This is note 2' }

    subject(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_note note_1
        c.with_note do
          note_2
        end
      end
    end

    it 'adds the notes' do
      within('table tfoot') do
        expect(html).to have_content(note_1)
        expect(html).to have_content(note_2)
      end
    end
  end

  context 'when rendering rows' do
    shared_examples 'a customisable td element' do
      it 'adds the default classes' do
        expect(html).to have_css('td.text-right')
      end

      context 'when specifying custom classes' do
        subject(:html) do
          render_inline(described_class.new(**params)) do |c|
            c.with_row do |r|
              r.with_var classes: 'text-left' do
                'Test'
              end
            end
          end
        end

        it 'adds those classes' do
          expect(html).to have_css('td.text-left')
        end
      end
    end

    shared_examples 'a td element with a data-order' do
      it { expect(html).to have_selector("td[data-order='#{expected_order}']")}
    end

    shared_examples 'a td element without a data-order' do
      it { expect(html).not_to have_selector('td[data-order]')}
    end

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
      let(:reference_params) {}
      let(:content) {}

      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_reference(**reference_params) { content }
          end
        end
      end

      context 'with a label, description and params' do
        let(:reference_params) { { label: 't', description: 'my reference with %{sub}', sub: 'parameters' } }

        it 'adds the reference' do
          expect(html).to have_content('[t] my reference with parameters')
        end

        context 'with missing params' do
          let(:reference_params) { { label: 't', description: 'my reference with %{sub}' } }

          it 'raises KeyError' do
            expect { html }.to raise_error(KeyError)
          end
        end
      end

      context 'with a footnote key and params' do
        let!(:footnote) { create(:footnote, key: 'note', label: 't', description: 'my reference with %{sub}')}
        let(:reference_params) { { key: 'note', sub: 'parameters' } }

        it 'adds the reference' do
          expect(html).to have_content('[t] my reference with parameters')
        end

        context 'with missing params' do
          let(:reference_params) { { key: 'note' } }

          it 'raises KeyError' do
            expect { html }.to raise_error(KeyError)
          end
        end
      end
    end

    context 'with var as a block' do
      let(:value) { 'Data' }
      let(:data_order) { nil }

      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_var data_order: data_order do
              value
            end
          end
        end
      end

      it 'adds the variable' do
        expect(html).to have_content(value)
      end

      it_behaves_like 'a customisable td element'
      it_behaves_like 'a td element without a data-order'

      context 'when an order is specified' do
        let(:data_order) { '2000' }

        it_behaves_like 'a td element with a data-order' do
          let(:expected_order) { data_order }
        end
      end
    end

    context 'with var to be formatted' do
      let(:value) { 100 }
      let(:unit) { :£ }
      let(:data_order) { nil }

      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_var val: value, unit: unit, data_order: data_order
          end
        end
      end

      context 'with money' do
        let(:unit)  { :£ }

        it 'adds the formatted value' do
          expect(html).to have_content('£100')
        end

        it_behaves_like 'a td element with a data-order' do
          let(:expected_order) { value }
        end
      end

      context 'with a date' do
        let(:value) { Date.new(2024, 1, 1) }
        let(:unit)  { :date }

        it 'adds the formatted value' do
          expect(html).to have_content('Monday  1 Jan 2024')
        end

        it_behaves_like 'a td element with a data-order' do
          let(:expected_order) { '2024-01-01' }
        end
      end

      it_behaves_like 'a customisable td element'

      context 'when a data_order is specified' do
        let(:data_order) { '2000' }

        it_behaves_like 'a td element with a data-order' do
          let(:expected_order) { data_order }
        end
      end
    end

    context 'with var to be formatted as a change' do
      let(:value) { 0.5 }
      let(:data_order) { nil }

      subject(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_row do |r|
            r.with_var val: value, unit: :relative_percent_0dp, change: true, data_order: data_order
          end
        end
      end

      it 'adds the formatted value' do
        expect(html).to have_content('+50&percnt;')
        expect(html).to have_css('i.fa-arrow-circle-up')
      end

      it_behaves_like 'a customisable td element'
      it_behaves_like 'a td element with a data-order' do
        let(:expected_order) { value }
      end
    end
  end
end
