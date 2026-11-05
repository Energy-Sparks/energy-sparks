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
    before do
      render_inline(component)
    end

    context 'when showing visibility button' do
      it { expect(page).to have_css('a i.fa-eye') }
      it { expect(page).to have_link(href: school_visibility_path(school)) }
      it { expect(page).to have_css('a[title="School is visible on the website"]') }

      context 'when not visible' do
        let(:school) { create(:school, visible: false) }

        it { expect(page).to have_css('a i.fa-eye') }
        it { expect(page).to have_link(href: school_visibility_path(school)) }
        it { expect(page).to have_css('a[title="School is not visible on the website"]') }
      end
    end

    context 'when showing process data button' do
      it { expect(page).to have_css('a i.fa-play') }
      it { expect(page).to have_link(href: school_data_processing_path(school)) }
      it { expect(page).to have_css('a[title="School data is being analysed"]') }

      context 'when not processing data' do
        let(:school) { create(:school, process_data: false) }

        it { expect(page).to have_css('a i.fa-eye') }
        it { expect(page).to have_link(href: school_data_processing_path(school)) }
        it { expect(page).to have_css('a[title="School data is not being analysed"]') }
      end
    end

    context 'when showing data enabled button' do
      it { expect(page).to have_css('a i.fa-chart-simple') }
      it { expect(page).to have_link(href: school_data_enabled_path(school)) }
      it { expect(page).to have_css('a[title="School data is visible"]') }

      context 'when not data enabled' do
        let(:school) { create(:school, data_enabled: false) }

        it { expect(page).to have_no_link(href: school_data_enabled_path(school)) }
        it { expect(page).to have_link(href: school_review_path(school)) }
        it { expect(page).to have_css('a[title="Review school to make data visible"]') }
      end
    end

    context 'when showing data sharing settings' do
      it { expect(page).to have_css('a i.fa-unlock-keyhole') }
      it { expect(page).to have_link(href: edit_school_configuration_path(school)) }
      it { expect(page).to have_text('Public') }

      context 'when sharing withing group' do
        let(:school) { create(:school, data_sharing: :within_group) }

        it { expect(page).to have_text('Within Group') }
      end

      context 'when private' do
        let(:school) { create(:school, data_sharing: :private) }

        it { expect(page).to have_text('Private') }
      end
    end

    context 'when showing licence' do
      it { expect(page).to have_css('a i.fa-file-contract') }
      it { expect(page).to have_text('Unlicensed') }

      context 'when school is licensed' do
        let!(:licence) { create(:commercial_licence) }

        let(:school) { licence.school }

        it { expect(page).to have_text(licence.end_date.strftime('%d-%m-%Y')) }
      end
    end

    context 'when showing regenerate button' do
      it { expect(page).to have_css('a i.fa-arrows-rotate') }
      it { expect(page).to have_link(href: school_batch_runs_path(school)) }

      context 'when school is not set to process data' do
        let(:school) { create(:school, process_data: false) }

        it { expect(page).to have_no_link(href: school_batch_runs_path(school)) }
      end
    end
  end
end
