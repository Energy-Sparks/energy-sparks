# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Forms::EmailReportButtonComponent, :include_application_helper, type: :component do
  context 'without block' do
    before do
      render_inline described_class.new('http://example.org', 'The label')
    end

    it { expect(page).to have_text('The label') }
    it { expect(page).to have_css("form[action='http://example.org'][method='post']") }
  end

  context 'with block' do
    let(:current_user) { create(:user) }

    before do
      render_inline described_class.new('http://example.org', 'The label', current_user:) do
        'More'
      end
    end

    it { expect(page).to have_text('The label') }
    it { expect(page).to have_css("form[action='http://example.org'][method='post']") }
    it { expect(page).to have_css('div.modal') }
    it { expect(page).to have_text(current_user.email) }
    it { expect(page).to have_text('More') }
  end
end
