require 'rails_helper'

describe Transifex::Service, type: :service do

  let(:project)         { 'es-test' }
  let(:api_key)         { '1/123abc' }
  let(:client)          { Transifex::Client.new(api_key, project) }
  let(:service)         { Transifex::Service.new(client) }

  describe '#reviews_completed?' do
    let(:tx_response)   { File.read('spec/fixtures/transifex/get_resource_language_stats_with_params.json') }
    let(:data)          { JSON.parse(tx_response)["data"] }

    context 'and reviews are completed' do
      let(:tx_response) { File.read('spec/fixtures/transifex/get_resource_language_stats_with_params_completed.json') }
      before(:each) do
        expect(client).to receive(:get_resource_language_stats).and_return(data)
      end

      it 'returns true' do
        expect(service.reviews_completed?("slug", :cy)).to be true
      end
    end

    context 'and reviews are not completed' do
      before(:each) do
        expect(client).to receive(:get_resource_language_stats).and_return(data)
      end

      it 'returns true' do
        expect(service.reviews_completed?("slug", :cy)).to be false
      end
    end
  end

  describe '#last_reviewed' do
    let(:tx_response)   { File.read('spec/fixtures/transifex/get_resource_language_stats_with_params.json') }
    let(:data)          { JSON.parse(tx_response)["data"] }

    context 'and reviews are completed' do
      let(:tx_response) { File.read('spec/fixtures/transifex/get_resource_language_stats_with_params.json') }
      before(:each) do
        expect(client).to receive(:get_resource_language_stats).and_return(data)
      end

      it 'returns true' do
        expect(service.last_reviewed("slug", :cy)).to eq(DateTime.parse("2022-06-15T14:30:49Z"))
      end
    end

  end

  describe '#create_resource' do
    let(:tx_response) { File.read('spec/fixtures/transifex/create_resource.json') }
    let(:data)          { JSON.parse(tx_response)["data"] }
    before(:each) do
      expect(client).to receive(:create_resource).and_return(data)
    end

    it 'returns creates the resource' do
      expect(service.create_resource("name", "slug", [])).to eq(data)
    end
  end

  describe '#push' do
    context 'and upload is successful' do
      it 'returns true'
    end
    context 'and upload fails' do
      it 'throws an error if failed'
    end
  end

  describe '#pull' do
    let(:tx_response)     { File.read('spec/fixtures/transifex/get_resource_translations_async_downloads_pending.json') }
    let(:data)            { JSON.parse(tx_response)["data"] }
    let(:yaml)            { "en:\n foo: bar" }

    before(:each) do
      expect(client).to receive(:create_resource_translations_async_downloads).and_return(data)
      expect(client).to receive(:get_resource_translations_async_download).and_return(yaml)
    end

    it 'fetches the file' do
      yaml = service.pull("slug", :cy)
      expect(yaml[:en]).to eq({foo: "bar"})
    end
  end

end
