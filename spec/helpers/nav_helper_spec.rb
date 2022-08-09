require 'rails_helper'

describe NavHelper do
  describe '#locale_switcher_buttons' do
    it 'returns buttons for all available locales except the current locale' do
      I18n.locale = 'en'
      allow(helper).to receive(:url_for) { 'http://cy.energysparks.uk/' }
      expect(helper.locale_switcher_buttons).to eq('<ul class="navbar-nav"><li class="nav-item pl-3 pr-3 nav-lozenge nav-lozenge-little-padding"><a href="http://cy.energysparks.uk/">Cymraeg</a></li></ul>')
      I18n.locale = 'cy'
      allow(helper).to receive(:url_for) { 'http://energysparks.uk/' }
      expect(helper.locale_switcher_buttons).to eq('<ul class="navbar-nav"><li class="nav-item pl-3 pr-3 nav-lozenge nav-lozenge-little-padding"><a href="http://energysparks.uk/">English</a></li></ul>')
      I18n.locale = 'en'
    end
  end

  describe '#locale_name_for' do
    it 'returns the subdomain for a given locale' do
      expect(helper.locale_name_for('en')).to eq('English')
      expect(helper.locale_name_for('cy')).to eq('Cymraeg')
    end
  end

  describe '#subdomain_for' do
    it 'returns the subdomain for a given locale' do
      expect(helper.subdomain_for('en')).to eq('')
      expect(helper.subdomain_for('cy')).to eq('cy')
    end
  end
end
