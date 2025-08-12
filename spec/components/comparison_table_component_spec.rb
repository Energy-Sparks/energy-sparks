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
    let(:note_3) { 'This is note 3' }
    let(:condition) { true }

    subject(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_note note: note_1
        c.with_note do
          note_2
        end
        c.with_note if: condition do
          note_3
        end
      end
    end

    it 'adds the notes' do
      within('table tfoot') do
        expect(html).to have_content(note_1)
        expect(html).to have_content(note_2)
        expect(html).to have_content(note_3)
      end
    end

    context 'when conditon is false' do
      let(:condition) { false }

      it 'does not add note' do
        expect(html).not_to have_content(note_3)
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
      let(:reference_params_1) {}
      let(:reference_params_2) {}
      let(:reference_params_3) {}
      let(:content) {}
      let(:current_user) { }

      before do
        # This allows us to set the current user during rendering
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
      end

      subject(:html) do
        with_controller_class ApplicationController do
          render_inline(described_class.new(**params)) do |c|
            c.with_row do |r|
              r.with_reference(**reference_params_1) { content }
              r.with_reference(**reference_params_2) if reference_params_2
            end
            c.with_row do |r|
              r.with_reference(**reference_params_3) if reference_params_3
            end
          end
        end
      end

      context 'with a label, description and params' do
        let(:reference_params_1) { { label: 't', description: 'my reference with %{sub}', sub: 'parameters' } }

        it 'has the reference' do
          expect(html).to have_css('sup[data-content="t: my reference with parameters"]', text: '[t]')
        end

        it 'adds the footnote' do
          expect(html).to have_content('[t] my reference with parameters')
        end

        context 'with missing params' do
          let(:reference_params_1) { { label: 't', description: 'my reference with %{sub}' } }

          it 'raises KeyError' do
            expect { html }.to raise_error(KeyError)
          end
        end

        context 'when current user is admin' do
          let(:current_user) { create(:admin) }

          it 'does not have edit link' do
            expect(html).not_to have_link('Edit')
          end
        end
      end

      context 'with a footnote key and params' do
        let!(:footnote) { create(:footnote, key: 'footnote_one', label: 't', description: 'my reference with %{sub}')}
        let(:reference_params_1) { { key: 'footnote_one', sub: 'parameters' } }

        it 'has the reference' do
          expect(html).to have_css('sup[data-content="t: my reference with parameters"]', text: '[t]')
        end

        it 'has the footnote' do
          expect(html).to have_content('[t] my reference with parameters')
        end

        context 'with missing params' do
          let(:reference_params_1) { { key: 'footnote_one' } }

          it 'raises KeyError' do
            expect { html }.to raise_error(KeyError)
          end
        end

        context 'with a second reference' do
          let!(:footnote_2) { create(:footnote, key: 'footnote_two', label: 'a', description: 'footnote two') }
          let(:reference_params_2) { { key: 'footnote_two' } }

          it 'has the reference' do
            expect(html).to have_css('sup[data-content="a: footnote two"]', text: '[a]')
          end

          it 'has the footnote' do
            expect(html).to have_content('[a] footnote two')
          end

          it 'orders the footnotes' do
            expect(html).to have_content(/\[a\] footnote two\s+\[t\] my reference with parameters/)
          end
        end

        context 'when same reference is added on two rows' do
          let(:reference_params_3) { { key: 'footnote_one', sub: 'parameters' } }

          it 'shows the footnote once' do
            expect(html).to have_content('[t] my reference with parameters').once
          end
        end

        context 'when current user is not admin' do
          let(:current_user) { }

          it 'does not show edit link' do
            expect(html).not_to have_link('Edit')
          end
        end

        context 'when current user is admin' do
          let(:current_user) { create(:admin) }

          it 'has edit link' do
            expect(html).to have_link('Edit', href: edit_admin_comparisons_footnote_path(footnote))
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
        expect(html).to have_content('+50%')
        expect(html).to have_css('i.fa-arrow-circle-up')
      end

      it_behaves_like 'a customisable td element'
      it_behaves_like 'a td element with a data-order' do
        let(:expected_order) { value }
      end
    end
  end
end
