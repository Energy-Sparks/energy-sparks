# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardHeaderComponent, type: :component do
  let(:school) { create(:school) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:params) do
    {
      id: id,
      classes: classes,
      school: school
    }
  end

  let(:html) { render_inline(described_class.new(**params)) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  it { expect(html).to have_content(school.name) }
  it { expect(html).to have_content(school.address) }
  it { expect(html).to have_content(school.postcode) }
  it { expect(html).to have_content(I18n.t("common.school_types.#{school.school_type}")) }
end
