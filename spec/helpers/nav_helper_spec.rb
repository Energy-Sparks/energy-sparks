require 'rails_helper'

describe NavHelper do
  describe '#locale_switcher_buttons' do
    it 'returns buttons for all available locales except the current locale' do
      I18n.locale = 'en'
      allow(helper).to receive(:url_for) { 'http://cy.energysparks.uk/' }
      expect(helper.locale_switcher_buttons).to eq('<a class="nav-item pl-3 pr-3 nav-lozenge nav-lozenge-little-padding" href="http://cy.energysparks.uk/">Cymraeg</a>')
      I18n.locale = 'cy'
      allow(helper).to receive(:url_for) { 'http://energysparks.uk/' }
      expect(helper.locale_switcher_buttons).to eq('<a class="nav-item pl-3 pr-3 nav-lozenge nav-lozenge-little-padding" href="http://energysparks.uk/">English</a>')
      I18n.locale = 'en'
    end
  end
end
