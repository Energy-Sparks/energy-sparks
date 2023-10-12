require 'rails_helper'

describe Transifex::Service, type: :service do
  let(:project)         { 'es-test' }
  let(:api_key)         { '1/123abc' }
  let(:max_tries)       { 3 }
  let(:client)          { Transifex::Client.new(api_key, project) }
  let(:service)         { Transifex::Service.new(client, max_tries, 0.1) }

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

  describe '#created_in_transifex?' do
    context 'when resource exists' do
      let(:tx_response)   { File.read('spec/fixtures/transifex/get_resource.json') }
      let(:data)          { JSON.parse(tx_response)["data"] }
      before(:each) do
        expect(client).to receive(:get_resource).and_return(data)
      end
      it 'returns true' do
        expect(service.created_in_transifex?("slug")).to be_truthy
      end
    end
    context 'when resource does not exist' do
      before(:each) do
        expect(client).to receive(:get_resource).and_raise(Transifex::Client::NotFound.new('test'))
      end
      it 'returns false' do
        expect(service.created_in_transifex?("slug")).to be_falsey
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
    let(:tx_create_response)    { File.read('spec/fixtures/transifex/create_resource_strings_async_upload.json') }
    let(:create_data)           { JSON.parse(tx_create_response)["data"] }
    let(:get_data)              { JSON.parse(tx_get_response)["data"] }
    let(:hash_for_yaml)         { { 'en' => { 'name' => 'wibble' } } }

    before(:each) do
      expect(client).to receive(:create_resource_strings_async_upload).and_return(create_data)
    end

    context 'and upload is successful' do
      let(:tx_get_response)       { File.read('spec/fixtures/transifex/get_resource_strings_collection.json') }
      let(:response)              { Transifex::Response.new(completed: true, data: get_data) }

      before do
        expect(client).to receive(:get_resource_strings_async_upload).and_return(response)
      end

      it 'returns true' do
        expect(service.push("slug", hash_for_yaml)).to be_truthy
      end
    end

    context 'and upload never finishes' do
      let(:tx_get_response)       { File.read('spec/fixtures/transifex/get_resource_strings_async_upload_pending.json') }
      let(:response)              { Transifex::Response.new(completed: false, data: get_data) }

      before do
        expect(client).to receive(:get_resource_strings_async_upload).exactly(max_tries).times.and_return(response)
      end

      it 'returns false after max tries' do
        expect(service.push("slug", hash_for_yaml)).to be_falsey
      end
    end

    context 'and upload fails' do
      before do
        expect(client).to receive(:get_resource_strings_async_upload).and_raise(Transifex::Client::ResponseError.new('test'))
      end
      it 'raises error' do
        expect do
          service.push("slug", hash_for_yaml)
        end.to raise_error(Transifex::Client::ResponseError)
      end
    end
  end

  describe '#pull' do
    let(:tx_create_response)     { File.read('spec/fixtures/transifex/create_resource_translations_async_downloads.json') }
    let(:create_data)            { JSON.parse(tx_create_response)["data"] }

    before(:each) do
      expect(client).to receive(:create_resource_translations_async_downloads).and_return(create_data)
    end

    context 'and download is successful' do
      let(:content_yaml)           { "cy:\n  name: Hwyl fawr\n" }
      let(:response)               { Transifex::Response.new(completed: true, content: content_yaml) }

      before do
        expect(client).to receive(:get_resource_translations_async_download).and_return(response)
      end

      it 'fetches the file' do
        yaml = service.pull("slug", :cy)
        expect(yaml['cy']).to eq({ 'name' => 'Hwyl fawr' })
      end
    end

    context 'and download never completes' do
      let(:tx_get_response)        { File.read('spec/fixtures/transifex/get_resource_translations_async_downloads_pending.json') }
      let(:get_data)               { JSON.parse(tx_get_response)["data"] }
      let(:response)               { Transifex::Response.new(completed: false, data: get_data) }

      before do
        expect(client).to receive(:get_resource_translations_async_download).exactly(max_tries).times.and_return(response)
      end

      it 'returns false after max tries' do
        expect(service.pull("slug", :cy)).to be_falsey
      end
    end

    context 'and download fails' do
      before do
        expect(client).to receive(:get_resource_translations_async_download).and_raise(Transifex::Client::ResponseError.new('test'))
      end
      it 'raises error' do
        expect do
          service.pull("slug", :cy)
        end.to raise_error(Transifex::Client::ResponseError)
      end
    end
  end

  describe '#clear_resources' do
    let(:item_1)          { { "id" => "o:energy-sparks:p:es-development:r:activity_type_1", "attributes" => { "slug" => "activity_type_1" } } }
    let(:item_2)          { { "id" => "o:energy-sparks:p:es-development:r:activity_type_2", "attributes" => { "slug" => "activity_type_2" } } }
    let(:items)           { [item_1, item_2] }

    context 'when deletions succeed' do
      before(:each) do
        expect(client).to receive(:list_resources).and_return(items)
        expect(client).to receive(:delete_resource).with('activity_type_1').and_return(true)
        expect(client).to receive(:delete_resource).with('activity_type_2').and_return(true)
      end

      it 'returns true' do
        expect(service.clear_resources).to be_truthy
      end
    end

    context 'when deletions fail' do
      before(:each) do
        expect(client).to receive(:list_resources).and_return(items)
        expect(client).to receive(:delete_resource).with('activity_type_1').and_raise(Transifex::Client::NotAllowed.new('test'))
      end

      it 'raises error' do
        expect do
          service.clear_resources
        end.to raise_error(Transifex::Client::NotAllowed)
      end
    end
  end
end
