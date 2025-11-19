require 'rails_helper'

RSpec.describe SchoolSearchComponent, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:tab) { SchoolSearchComponent::DEFAULT_TAB }
  let(:letter) { 'A' }
  let(:schools) { School.active }
  let(:school_groups) { SchoolGroup.organisation_groups }
  let(:keyword) { nil }
  let(:id) { 'my-id' }
  let(:classes) { 'custom-class' }

  let(:params) do
    {
      tab: tab,
      schools: schools,
      school_groups: school_groups,
      letter: letter,
      keyword: keyword,
      id: id,
      classes: classes
    }
  end

  let!(:a_school_group) { create(:school_group, name: 'A Group') }
  let!(:b_school_group) { create(:school_group, name: 'B Group') }
  let!(:numbered_school_group) { create(:school_group, name: '5 Group') }

  let!(:a_school) { create(:school, :with_school_group, active: true, visible: true, name: 'A School') }
  let!(:b_school) { create(:school, :with_school_group, active: true, visible: true, name: 'B School') }
  let!(:c_school) { create(:school, :with_school_group, active: true, visible: true, name: 'C School') }
  let!(:numbered_school) { create(:school, :with_school_group, active: true, visible: true, name: '5 School') }

  before do
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
    context 'with active tab' do
      it { expect(component.letter_status(:schools, 'A')).to eq('active') }
      it { expect(component.letter_status(:schools, 'B')).to be_nil }
      it { expect(component.letter_status(:schools, 'C')).to be_nil }
      it { expect(component.letter_status(:schools, 'Z')).to eq('disabled') }
      it { expect(component.letter_status(:schools, '#')).to be_nil }
    end

    context 'with inactive tab' do
      it { expect(component.letter_status(:school_groups, 'A')).to eq('active') }
      it { expect(component.letter_status(:school_groups, 'B')).to be_nil }
      it { expect(component.letter_status(:school_groups, 'Z')).to eq('disabled') }
      it { expect(component.letter_status(:school_groups, '#')).to be_nil }
    end
  end

  describe '#schools_count' do
    it { expect(component.schools_count).to eq(4) }

    context 'with alternate scope' do
      let(:schools) { School.all } # all schools, including inactive ones

      it { expect(component.schools_count).to eq(8) }
    end
  end

  describe '#school_groups_count' do
    # every school has its own group in the default setup
    it { expect(component.school_groups_count).to eq(11) }

    context 'with alternate scope' do
      let(:school_groups) { SchoolGroup.local_authority }

      before do
        create(:school_group, group_type: :local_authority)
      end

      it { expect(component.school_groups_count).to eq(1) }
    end

    context 'with visible schools' do
      let(:school_groups) { SchoolGroup.organisation_groups.with_visible_schools }

      it { expect(component.school_groups_count).to eq(8) }
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
    context 'with active tab' do
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
    end

    context 'with inactive tab' do
      context 'with letter' do
        let(:letter) { 'C' } # ignored as on the default tab we should first letter of alphabet

        it { expect(component.default_results(:school_groups)).to eq([a_school_group])}
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
      %w[schools school-groups].each do |tab|
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
