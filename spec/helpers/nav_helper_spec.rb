require 'rails_helper'

describe NavHelper do
  describe '#locale_name_for' do
    it 'returns the name for a given locale' do
      I18n.locale = :cy
      expect(helper.locale_name_for('en')).to eq('English')
      I18n.locale = :en
      expect(helper.locale_name_for('cy')).to eq('Cymraeg')
    end
  end

  describe '#navigation_image_link' do
    it 'links to the home page' do
      expect(helper.navigation_image_link).to have_link(href: '/home-page')
    end

    it 'returns the Welsh logo' do
      I18n.with_locale(:cy) do
        expect(helper.navigation_image_link).to include 'navigation-brand-transparent-cy'
      end
    end

    it 'returns the English logo' do
      I18n.with_locale(:en) do
        expect(helper.navigation_image_link).to include 'navigation-brand-transparent-en'
      end
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
