require 'rails_helper'

RSpec.describe SchoolSearchComponent, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:tab) { SchoolSearchComponent::DEFAULT_TAB }
  let(:letter) { 'A' }
  let(:schools) { School.active }
  let(:keyword) { nil }
  let(:id) { 'my-id' }
  let(:classes) { 'custom-class' }

  let(:params) do
    {
      tab: tab,
      schools: schools,
      letter: letter,
      keyword: keyword,
      id: id,
      classes: classes
    }
  end

  let!(:a_school_group) { create(:school_group, name: 'A Group') }
  let!(:b_school_group) { create(:school_group, name: 'B Group') }
  let!(:x_school_group) { create(:school_group, name: 'X Group') }
  let!(:numbered_school_group) { create(:school_group, name: '5 Group') }

  let!(:a_school) { create(:school, school_group: a_school_group, active: true, visible: true, name: 'A School') }
  let!(:b_school) { create(:school, school_group: b_school_group, active: true, visible: true, name: 'B School') }
  let!(:c_school) { create(:school, :with_school_group, active: true, visible: true, name: 'C School') }
  let!(:numbered_school) { create(:school, school_group: numbered_school_group, active: true, visible: true, name: '5 School') }

  before do
    Flipper.enable(:find_new_group_types)
    %w[A B C 5].each do |letter|
      create(:school, :with_school_group, active: false, name: "#{letter} Inactive School",)
    end
  end

  describe '.sanitize_tab' do
    it { expect(described_class.sanitize_tab(:schools)).to eq(:schools) }
    it { expect(described_class.sanitize_tab(:school_groups)).to eq(:school_groups) }
    it { expect(described_class.sanitize_tab(:diocese)).to eq(:diocese) }
    it { expect(described_class.sanitize_tab(:areas)).to eq(:areas) }

    it { expect(described_class.sanitize_tab(:invalid)).to eq(SchoolSearchComponent::DEFAULT_TAB) }
  end

  describe '#letter_status' do
    context 'when on default (schools) tab' do
      it { expect(component.letter_status(:schools, 'A')).to eq('active') } # highlighted by default
      it { expect(component.letter_status(:schools, 'B')).to be_nil }
      it { expect(component.letter_status(:schools, 'C')).to be_nil }
      it { expect(component.letter_status(:schools, 'Z')).to eq('disabled') } # no schools
      it { expect(component.letter_status(:schools, '#')).to be_nil }

      context 'when no letter selected' do
        let(:letter) { nil }

        it { expect(component.letter_status(:schools, 'A')).to eq('active') } # highlighted by default
      end

      context 'when B selected' do
        let(:letter) { 'B' }

        it { expect(component.letter_status(:schools, 'B')).to eq('active') }
        it { expect(component.letter_status(:schools, 'A')).to be_nil }
      end

      context 'with school groups tab' do
        it { expect(component.letter_status(:school_groups, 'A')).to eq('active') }
        it { expect(component.letter_status(:school_groups, 'B')).to be_nil }
        it { expect(component.letter_status(:school_groups, 'X')).to eq('disabled') } # no visible schools
        it { expect(component.letter_status(:school_groups, 'Z')).to eq('disabled') } # no group
        it { expect(component.letter_status(:school_groups, '#')).to be_nil }
      end
    end

    context 'when on dicoese tab' do
      let!(:diocese) { create(:school_group, group_type: :diocese, name: 'Diocese of Bath and Wells') }
      let(:letter) { 'B' }

      it { expect(component.letter_status(:schools, 'D')).to eq('disabled') } # prefix ignored
      it { expect(component.letter_status(:schools, 'B')).to eq('active') } # prefix removed
    end
  end

  describe '#schools_count' do
    it { expect(component.schools_count).to eq(4) }

    context 'with alternate scope' do
      let(:schools) { School.all } # all schools, including inactive ones

      it { expect(component.schools_count).to eq(8) }
    end
  end

  describe '#letter_title' do
    it { expect(component.letter_title(:schools, 'A')).to eq('1 school') }
    it { expect(component.letter_title(:school_groups, 'A')).to eq('1 school group') }
  end

  describe '#label' do
    it { expect(component.label(:schools, 'content')).to eq('schools-content')}
    it { expect(component.label(:school_groups, 'tab')).to eq('school-groups-tab')}
  end

  describe '#default_results' do
    context 'when showing schools tab' do
      context 'with keyword' do
        let(:keyword) { 'B' }

        it { expect(component.default_results(:schools)).to eq([b_school])}
      end

      context 'with longer keyword' do
        let(:keyword) { 'School' }

        it { expect(component.default_results(:schools)).to eq([numbered_school, a_school, b_school, c_school]) }
      end

      context 'with letter' do
        let(:letter) { 'C' }

        it { expect(component.default_results(:schools)).to eq([c_school])}
      end

      context 'with #' do
        let(:letter) { '#' }

        it { expect(component.default_results(:schools)).to eq([numbered_school])}
      end

      context 'with the inactive school group tab' do
        context 'with letter' do
          let(:letter) { 'C' } # ignored as on the default tab we should show the first letter of alphabet

          it { expect(component.default_results(:school_groups)).to eq([a_school_group])}
        end
      end
    end

    context 'when showing school groups tab' do
      let(:tab) { :school_groups }

      context 'with letter' do
        let(:letter) { 'B' }

        it { expect(component.default_results(:school_groups)).to eq([b_school_group])}
      end

      context 'with keyword' do
        let(:keyword) { 'B' }

        it { expect(component.default_results(:school_groups)).to eq([b_school_group])}
      end
    end

    context 'when showing diocese tab' do
      let!(:diocese) do
        diocese = create(:school_group, group_type: :diocese, name: 'Diocese of Bath and Wells')
        create(:school, :with_diocese, group: diocese)
        diocese
      end

      let(:tab) { :diocese }

      context 'with letter' do
        let(:letter) { 'B' }

        it { expect(component.default_results(:diocese)).to eq([diocese])}
      end

      context 'with keyword' do
        let(:keyword) { 'B' }

        it { expect(component.default_results(:diocese)).to eq([diocese])}
      end
    end
  end

  describe '#default_results_title' do
    context 'with active tab' do
      context 'with keyword' do
        let(:keyword) { 'B' }

        it { expect(component.default_results_title(:schools)).to eq(I18n.t('components.search_results.keyword.title'))}
      end

      context 'with letter' do
        let(:letter) { 'C' }

        it { expect(component.default_results_title(:schools)).to eq(letter)}
      end

      context 'with number' do
        let(:letter) { '#' }

        it { expect(component.default_results_title(:schools)).to eq(letter)}
      end
    end

    context 'with inactive tab' do
      context 'with letter' do
        let(:letter) { 'C' } # ignored as on the default tab we should first letter of alphabet

        it { expect(component.default_results_title(:school_groups)).to eq('A')}
      end
    end
  end

  describe '#default_results_subtitle' do
    context 'with active tab' do
      context 'with keyword' do
        let(:keyword) { 'B' }

        it { expect(component.default_results_subtitle(:schools)).to eq(I18n.t('components.search_results.schools.subtitle', count: 1))}
      end

      context 'with letter' do
        let(:letter) { 'C' }

        it { expect(component.default_results_subtitle(:schools)).to eq(I18n.t('components.search_results.schools.subtitle', count: 1))}
      end

      context 'with number' do
        let(:letter) { '#' }

        it { expect(component.default_results_subtitle(:schools)).to eq(I18n.t('components.search_results.schools.subtitle', count: 1))}
      end
    end

    context 'with inactive tab' do
      context 'with letter' do
        let(:letter) { 'C' } # ignored as on the default tab we should first letter of alphabet

        it { expect(component.default_results_subtitle(:school_groups)).to eq(I18n.t('components.search_results.school_groups.subtitle', count: 1))}
      end
    end
  end

  context 'when rendering' do
    let(:html) { render_inline(component) }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it 'renders all the named tabs and sections' do
      %w[schools school-groups diocese areas].each do |tab|
        expect(html).to have_css("##{tab}-tab")
        expect(html).to have_css("##{tab}-content")
        expect(html).to have_css("##{tab}-results")
      end
    end

    context 'with schools tab' do
      it { expect(html).to have_link('A', href: schools_path(letter: 'A', scope: :schools))}
      it { expect(html).to have_link(a_school.name, href: school_path(a_school)) }
      it { expect(html).to have_content(a_school.school_group.name)}
    end

    context 'with school groups' do
      it { expect(html).to have_link('A', href: schools_path(letter: 'A', scope: :school_groups))}
      it { expect(html).to have_link(a_school_group.name, href: school_group_path(a_school_group)) }
    end
  end
end
