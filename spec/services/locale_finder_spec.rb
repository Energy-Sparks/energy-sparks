require 'rails_helper'

describe LocaleFinder do
  describe '.find_locale' do
    context 'when locale specified in params' do
      let(:params) { { locale: 'ab' } }
      let(:request) { double(subdomains: ['test-cy']) }

      it 'returns locale from params' do
        expect(LocaleFinder.new(params, request).locale).to match('ab')
      end
    end

    context 'when locale specified in subdomain' do
      let(:params) { {} }
      let(:request) { double(subdomains: ['test-cy']) }

      it 'returns locale from params' do
        expect(LocaleFinder.new(params, request).locale).to match('cy')
      end
    end

    context 'when subdomain locale not valid' do
      let(:params) { {} }
      let(:request) { double(subdomains: ['test-xx']) }

      it 'returns default locale' do
        expect(LocaleFinder.new(params, request).locale).to match('en')
      end
    end

    context 'when no subdomain' do
      let(:params) { {} }
      let(:request) { double(subdomains: []) }

      it 'returns default locale' do
        expect(LocaleFinder.new(params, request).locale).to match('en')
      end
    end
  end
end
