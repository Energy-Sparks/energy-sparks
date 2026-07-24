# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Forms::EmailReportButtonComponent, :include_application_helper, type: :component do
  before do
    render_inline described_class.new('http://example.org', 'The label')
  end

  it { expect(page).to have_text('The label') }
  it { expect(page).to have_css("form[action='http://example.org'][method='post']") }
end
