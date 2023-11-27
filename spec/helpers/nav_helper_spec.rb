require 'rails_helper'

describe NavHelper do
  describe '#locale_switcher_buttons' do
    it 'returns buttons for all available locales except the current locale' do
      I18n.locale = 'en'
      allow(helper).to receive(:url_for).and_return('http://cy.energysparks.uk/')
      expect(helper.locale_switcher_buttons).to eq('<ul class="navbar-nav navbar-expand"><li class="nav-item pl-3 pr-3 nav-lozenge nav-lozenge-little-padding"><a href="http://cy.energysparks.uk/">Cymraeg</a></li></ul>')
      I18n.locale = 'cy'
      allow(helper).to receive(:url_for).and_return('http://energysparks.uk/')
      expect(helper.locale_switcher_buttons).to eq('<ul class="navbar-nav navbar-expand"><li class="nav-item pl-3 pr-3 nav-lozenge nav-lozenge-little-padding"><a href="http://energysparks.uk/">English</a></li></ul>')
      I18n.locale = 'en'
    end
  end

  describe '#locale_name_for' do
    it 'returns the name for a given locale' do
      I18n.locale = 'cy'
      expect(helper.locale_name_for('en')).to eq('English')
      I18n.locale = 'en'
      expect(helper.locale_name_for('cy')).to eq('Cymraeg')
    end
  end

  describe '#subdomain_for' do
    it 'returns the subdomain for a given locale' do
      # With production application host environment values
      ENV['APPLICATION_HOST'] = 'energysparks.uk'
      ENV['WELSH_APPLICATION_HOST'] = 'cy.energysparks.uk'
      expect(ENV['APPLICATION_HOST']).to eq('energysparks.uk')
      expect(ENV['WELSH_APPLICATION_HOST']).to eq('cy.energysparks.uk')
      expect(helper.subdomain_for('en')).to eq('')
      expect(helper.subdomain_for('cy')).to eq('cy')
      expect(helper.subdomain_for('fr')).to eq('fr')

      # With test application host environment values
      ENV['APPLICATION_HOST'] = 'test.energysparks.uk'
      ENV['WELSH_APPLICATION_HOST'] = 'test-cy.energysparks.uk'
      expect(ENV['APPLICATION_HOST']).to eq('test.energysparks.uk')
      expect(ENV['WELSH_APPLICATION_HOST']).to eq('test-cy.energysparks.uk')
      expect(helper.subdomain_for('en')).to eq('test')
      expect(helper.subdomain_for('cy')).to eq('test-cy')
      expect(helper.subdomain_for('fr')).to eq('fr')

      # Without application host environment values set
      ENV.delete('APPLICATION_HOST')
      ENV.delete('WELSH_APPLICATION_HOST')
      expect(ENV['APPLICATION_HOST']).to eq(nil)
      expect(ENV['WELSH_APPLICATION_HOST']).to eq(nil)
      expect(helper.subdomain_for('en')).to eq('')
      expect(helper.subdomain_for('cy')).to eq('cy')
      expect(helper.subdomain_for('fr')).to eq('fr')
    end
  end
end
