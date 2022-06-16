require 'rails_helper'
require 'faraday/adapter/test'

module TransifexApi
  describe Client do
    let(:api_key)     { '1/123abc' }
    let(:project)     { 'es-test' }
    let(:status)      { 200 }
    let(:success)     { true }
    let(:response)    { double(status: status, 'success?' => success, body: body) }
    let(:connection)  { double(get: response) }

    let(:client)      { TransifexApi::Client.new(api_key, project, connection) }

    context '#get_languages' do
      let(:body)  { File.read('spec/fixtures/transifex/get_languages.json') }

      it 'requests correct url and returns data' do
        languages = client.get_languages
        expect(languages[0]["attributes"]["code"]).to eq('cy')
      end
    end

    context '#list_resources' do
      let(:body)  { File.read('spec/fixtures/transifex/list_resources.json') }

      it 'requests correct url and returns data' do
        resources = client.list_resources
        expect(resources[0]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1')
      end
    end

    context '#get_resource_language_stats' do
      context 'for project' do
        let(:body)  { File.read('spec/fixtures/transifex/get_resource_language_stats.json') }

        it 'adds resource and language to url if specified' do
          resource_language_stats = client.get_resource_language_stats
          expect(resource_language_stats[0]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:cy')
          expect(resource_language_stats[1]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:en')
        end
      end

      context 'for specified resource and language' do
        let(:body)  { File.read('spec/fixtures/transifex/get_resource_language_stats_with_params.json') }

        it 'adds resource and language to url if specified' do
          resource_language_stats = client.get_resource_language_stats('slug-jh1', 'cy')
          expect(resource_language_stats["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:cy')
          expect(resource_language_stats["attributes"]["untranslated_words"]).to eq(22)
        end
      end
    end
  end
end
