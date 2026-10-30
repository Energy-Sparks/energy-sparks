# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SchoolStatusButtonsComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(school:, current_user: create(:admin))
  end

  let(:school) { create(:school) }

  describe '#render?' do
    context 'with an admin' do
      it { expect(component.render?).to be(true) }
    end

    context 'with another user' do
      subject(:component) do
        described_class.new(school:, current_user: create(:school_admin))
      end

      it { expect(component.render?).to be(false) }
    end
  end

  context 'when rendering' do
    subject(:html) do
      render_inline(component)
    end

    context 'when showing visibility button' do
      it { expect(html).to have_css('a i.fa-eye') }
      it { expect(html).to have_link(href: school_visibility_path(school)) }
    end

    context 'when showing process data button' do
      it { expect(html).to have_css('a i.fa-play') }
      it { expect(html).to have_link(href: school_data_processing_path(school)) }
    end

    context 'when showing data enabled button' do
      it { expect(html).to have_css('a i.fa-chart-simple') }
      it { expect(html).to have_link(href: school_data_enabled_path(school)) }

      context 'when not data enabled' do
        let(:school) { create(:school, data_enabled: false) }

        it { expect(html).to have_no_link(href: school_data_enabled_path(school)) }
        it { expect(html).to have_link(href: school_review_path(school)) }
      end
    end

    context 'when showing licence' do
      it { expect(html).to have_css('a i.fa-file-contract') }
      it { expect(html).to have_text('Unlicensed') }

      context 'when school is licensed' do
        let!(:licence) { create(:commercial_licence, school:) }

        it { expect(html).to have_text(licence.end_date.iso8601) }
      end
    end

    context 'when showing regenerate button' do
      it { expect(html).to have_css('a i.fa-arrows-rotate') }
      it { expect(html).to have_link(href: school_batch_runs_path(school)) }

      context 'when school is not set to process data' do
        let(:school) { create(:school, process_data: false) }

        it { expect(html).to have_no_link(href: school_batch_runs_path(school)) }
      end
    end
  end
end
