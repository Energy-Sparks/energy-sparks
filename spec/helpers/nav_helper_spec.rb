require 'rails_helper'

describe NavHelper do
  let(:locale_switcher_buttons_feature) { true }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_LOCALE_SWITCHER_BUTTONS: locale_switcher_buttons_feature.to_s do
      example.run
    end
  end

  describe '#locale_switcher_buttons' do
    context 'with locale_switcher_buttons_feature switched on' do
      let(:locale_switcher_buttons_feature) { true }

      it 'returns buttons for all available locales except the current locale' do
        I18n.locale = 'en'
        allow(helper).to receive(:url_for).and_return('http://cy.energysparks.uk/')
        expect(helper.locale_switcher_buttons).to eq('<ul class="navbar-nav navbar-expand"><li class="nav-item pl-3 pr-3 nav-lozenge my-3px"><a href="http://cy.energysparks.uk/">Cymraeg</a></li></ul>')
        I18n.locale = 'cy'
        allow(helper).to receive(:url_for).and_return('http://energysparks.uk/')
        expect(helper.locale_switcher_buttons).to eq('<ul class="navbar-nav navbar-expand"><li class="nav-item pl-3 pr-3 nav-lozenge my-3px"><a href="http://energysparks.uk/">English</a></li></ul>')
        I18n.locale = 'en'
      end
    end

    context 'with locale_switcher_buttons_feature switched off' do
      let(:locale_switcher_buttons_feature) { false }

      it 'returns nothing' do
        allow(helper).to receive(:url_for).and_return('http://energysparks.uk/')
        expect(helper.locale_switcher_buttons).to eq('')
      end
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
