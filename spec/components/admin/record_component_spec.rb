# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::RecordComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(record, current_user:)
  end

  let(:created_by) { create(:pupil) }
  let(:updated_by) { create(:staff) }
  let(:current_user) { create(:admin) }

  let(:record) do
    create(:observation, :activity, created_by:, updated_by:, created_at: Date.yesterday, updated_at: Time.zone.today)
  end

  describe '#render?' do
    context 'with an admin' do
      it { expect(component.render?).to be(true)}
    end

    context 'with an school admin' do
      let(:current_user) { create(:school_admin, school: record.school) }

      it { expect(component.render?).to be(false)}
    end
  end

  context 'when rendering' do
    subject(:html) do
      render_inline(component)
    end

    it { expect(html).to have_content(record.created_at.to_fs(:es_compact))}
    it { expect(html).to have_content(record.updated_at.to_fs(:es_compact))}

    context 'with staff users' do
      it { expect(html).to have_link(updated_by.display_name, href: user_path(updated_by))}
    end

    context 'with pupil users' do
      it { expect(html).to have_content(created_by.display_name)}
      it { expect(html).to have_no_link(created_by.display_name, href: user_path(created_by))}
    end
  end
end
