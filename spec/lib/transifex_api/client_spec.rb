require 'rails_helper'
require 'faraday/adapter/test'

module TransifexApi
  describe Client do

    let(:stubs)       { Faraday::Adapter::Test::Stubs.new }
    let(:connection)  { Faraday.new { |b| b.adapter(:test, stubs) } }
    let(:api_key)     { '1/123abc' }
    let(:project)     { 'es-test' }

    let(:client)      { TransifexApi::Client.new(api_key, project, connection) }

    after(:all) do
      Faraday.default_connection = nil
    end

    context '#list_resources' do
      let(:data) {
        [{"id"=>"o:energy-sparks:p:es-test:r:slug1",
          "type"=>"resources",
          "attributes"=>
            {"slug"=>"slug-jh1",
             "name"=>"resource-jh1"}}]
      }

      let(:response) { { data: data } }

      it 'requests correct url and returns data' do
        stubs.get("/resources?filter[project]=o:energy-sparks:p:es-test") do |env|
          [200, {}, response.to_json]
        end
        resp = client.list_resources
        expect(resp[0]["id"]).to eq('o:energy-sparks:p:es-test:r:slug1')
        stubs.verify_stubbed_calls
      end
    end

    context '#get_resource_language_stats' do
      context 'for project' do

        let(:data) {
          [
            {"id"=>"o:energy-sparks:p:es-test:r:slug1:l:cy",
             "type"=>"resource_language_stats",
             "attributes"=>
               {"untranslated_words"=>22,
                "translated_words"=>0,}
            },
            {"id"=>"o:energy-sparks:p:es-test:r:slug1:l:en",
             "type"=>"resource_language_stats",
             "attributes"=>
               {"untranslated_words"=>0,
                "translated_words"=>22,}
            }
          ]
        }

        let(:response) { { data: data } }

        it 'adds resource and language to url if specified' do
          stubs.get("/resource_language_stats") do |env|
            [200, {}, response.to_json]
          end
          resp = client.get_resource_language_stats
          expect(resp[0]["id"]).to eq('o:energy-sparks:p:es-test:r:slug1:l:cy')
          expect(resp[1]["id"]).to eq('o:energy-sparks:p:es-test:r:slug1:l:en')
          stubs.verify_stubbed_calls
        end
      end

      context 'for specified resource and language' do

        let(:data) {
          {"id"=>"o:energy-sparks:p:es-test:r:slug1:l:cy",
           "type"=>"resource_language_stats",
           "attributes"=>
             {"untranslated_words"=>22,
              "translated_words"=>0,}
          }
        }

        let(:response) { { data: data } }

        it 'adds resource and language to url if specified' do
          stubs.get("/resource_language_stats/o:energy-sparks:p:es-test:r:slug1:l:cy") do |env|
            [200, {}, response.to_json]
          end
          resp = client.get_resource_language_stats('slug1', 'cy')
          expect(resp["id"]).to eq('o:energy-sparks:p:es-test:r:slug1:l:cy')
          expect(resp["attributes"]["untranslated_words"]).to eq(22)
          stubs.verify_stubbed_calls
        end
      end
    end
  end
end
