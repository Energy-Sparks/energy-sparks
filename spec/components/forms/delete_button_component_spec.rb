# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Forms::DeleteButtonComponent, :include_application_helper, type: :component do
  before do
    render_inline described_class.new('http://example.org')
  end

  it { expect(page).to have_link('Delete', href: 'http://example.org') }
  it { expect(page).to have_css('a.btn-danger') }

  context 'when different name' do
    before do
      render_inline described_class.new('http://example.org', 'Delete Me')
    end

    it { expect(page).to have_link('Delete Me', href: 'http://example.org') }
  end

  context 'with Deletable' do
    let(:deletable) { true }
    let(:resource) { double(deletable?: deletable) }

    before do
      render_inline described_class.new('http://example.org', resource:)
    end

    it { expect(page).to have_link('Delete', href: 'http://example.org') }

    context 'when cannot be deleted' do
      let(:deletable) { false }

      it { expect(page).to have_no_link('Delete', href: 'http://example.org') }
    end
  end
end
