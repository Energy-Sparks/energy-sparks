# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUserListComponent, :include_application_helper, :include_url_helpers do
  subject(:component) do
    described_class.new(**params)
  end

  let(:id) { 'custom-id'}
  let(:classes) { 'extra-classes' }
  let(:users) { [create(:admin)] }
  let(:school) { [create(:school)] }

  let(:params) do
    {
      schools: schools,
      users: users,
      id: id,
      classes: classes
    }
  end

  describe '#users_to_display' do
    context 'with users' do
      it 'yields all of the users'
    end

    context 'with schools' do
      it 'yields all school users'
    end
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it 'shows expected columns'
  end
end
