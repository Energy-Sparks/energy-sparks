require 'rails_helper'

module Transifex
  describe Client do
    let(:api_key)     { '1/123abc' }
    let(:project)     { 'es-test' }
    let(:status)      { 200 }
    let(:success)     { true }
    let(:body)        { { data: {} }.to_json }
    let(:response)    { double(status: status, 'success?' => success, body: body) }
    let(:connection)  { double(:faraday) }

    context 'when creating connection' do
      let(:client)    { Transifex::Client.new(api_key, project) }
      let(:headers)   { { "Authorization"=>"Bearer #{api_key}", "Content-Type"=>"application/vnd.api+json"} }

      it 'supplies headers' do
        expect(Faraday).to receive(:new).with(Transifex::Client::BASE_URL, headers: headers).and_return(connection)
        expect(connection).to receive(:get).and_return(response)
        client.get_languages
      end
    end

    context 'when using connection' do
      let(:client)      { Transifex::Client.new(api_key, project, connection) }

      context '#get_languages' do
        let(:body)          { File.read('spec/fixtures/transifex/get_languages.json') }
        let(:expected_path) { "projects/o:energy-sparks:p:#{project}/languages" }

        it 'requests url with path and returns data' do
          expect(connection).to receive(:get).with(expected_path).and_return(response)
          languages = client.get_languages
          expect(languages[0]["attributes"]["code"]).to eq('cy')
        end
      end

      context '#list_resources' do
        let(:body)          { File.read('spec/fixtures/transifex/list_resources.json') }
        let(:expected_path) { "resources?filter[project]=o:energy-sparks:p:#{project}" }

        it 'requests url with filter and returns data' do
          expect(connection).to receive(:get).with(expected_path).and_return(response)
          resources = client.list_resources
          expect(resources[0]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1')
        end
      end

      context '#get_resource_language_stats' do
        context 'for project' do
          let(:body)          { File.read('spec/fixtures/transifex/get_resource_language_stats.json') }
          let(:expected_path) { "resource_language_stats?filter[project]=o:energy-sparks:p:#{project}" }

          it 'requests url with filter and returns data' do
            expect(connection).to receive(:get).with(expected_path).and_return(response)
            resource_language_stats = client.get_resource_language_stats
            expect(resource_language_stats[0]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:cy')
            expect(resource_language_stats[1]["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:en')
          end
        end

        context 'for specified resource and language' do
          let(:body)          { File.read('spec/fixtures/transifex/get_resource_language_stats_with_params.json') }
          let(:slug)          { 'slug-jh1' }
          let(:language)      { 'cy' }
          let(:expected_path) { "resource_language_stats/o:energy-sparks:p:#{project}:r:#{slug}:l:#{language}" }

          it 'adds resource and language to url' do
            expect(connection).to receive(:get).with(expected_path).and_return(response)

            resource_language_stats = client.get_resource_language_stats(slug, language)

            expect(resource_language_stats["id"]).to eq('o:energy-sparks:p:es-development:r:slug-jh1:l:cy')
            expect(resource_language_stats["attributes"]["untranslated_words"]).to eq(22)
            expect(resource_language_stats["attributes"]["translated_words"]).to eq(0)
            expect(resource_language_stats["attributes"]["total_strings"]).to eq(12)
            expect(resource_language_stats["attributes"]["reviewed_strings"]).to eq(0)
            expect(resource_language_stats["attributes"]["last_review_update"]).to eq('2022-06-15T14:30:49Z')
            expect(resource_language_stats["relationships"]["language"]["data"]["id"]).to eq('l:cy')
          end
        end
      end
    end
  end
end
