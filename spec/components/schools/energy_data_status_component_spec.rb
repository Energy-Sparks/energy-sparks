# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::EnergyDataStatusComponent, :include_url_helpers, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:school) { create(:school) }

  let(:base_params) { { id: id, classes: classes, school: school } }

  subject(:html) do
    render_inline(described_class.new(**params))
  end


  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end
  end
end
