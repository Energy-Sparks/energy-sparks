require 'rails_helper'

describe HelpPageHelper do
  describe '.link_to_help_for_feature' do
    it 'handles undefined feature' do
      expect(helper.link_to_help_for_feature(:not_a_feature)).to be_nil
    end

    it 'handles missing page' do
      expect(helper.link_to_help_for_feature(:school_targets)).to be_nil
    end

    context 'when help page exists' do
      let!(:help_page) { create(:help_page, feature: :school_targets, title: "My School Targets", published: true) }
      it 'formats title' do
        expect(helper.link_to_help_for_feature(:school_targets, title: 'Info for school targets')).to have_content('Info for school targets')
      end

      it 'formats link' do
        expect(helper.link_to_help_for_feature(:school_targets, title: 'Info for school targets')).to include('/help/my-school-targets')
      end
    end
  end
end
