require 'rails_helper'

RSpec.describe BlogService, type: :service do
  include_context 'with cache'

  let(:fixture_path) { File.expand_path('spec/fixtures/files/blog-feed.xml', Dir.pwd) }
  let(:blog_xml) { File.read(fixture_path) }

  let(:blog) { BlogService.new }

  let(:basic_item) do
    {
      title: 'Title',
      image: 'image.jpg',
      description: 'Description',
      link: 'https://example.com/blog',
      date: '2025-04-11',
      categories: ['Category'],
      author: 'Author',
      author_link: 'https://example.com/author'
  }
  end

  let(:response_success) do
    instance_double(Faraday::Response, body: blog_xml, status: 200).tap do |r|
      allow(r).to receive(:success?).and_return(true)
    end
  end

  let(:response_success_empty) do
    instance_double(Faraday::Response, body: '', status: 200).tap do |r|
      allow(r).to receive(:success?).and_return(true)
    end
  end

  let(:response_error) do
    instance_double(Faraday::Response, body: 'Error 500', status: 500).tap do |r|
      allow(r).to receive(:success?).and_return(false)
    end
  end

  let(:response) { response_success }

  before do
    allow(blog.instance_variable_get(:@connection)).to receive(:get).and_return(response)
  end

  shared_examples 'a cache without the key' do
    it { expect(Rails.cache.exist?(blog.key)).to be false }
  end

  shared_examples 'a cache with the key' do
    it { expect(Rails.cache.exist?(blog.key)).to be true }
  end

  shared_examples 'items with expected fields' do |count:|
    it { expect(items.count).to be count }

    it 'contains items with the correct fields' do
      items.each_with_index do |item, x|
        expect(item[:title]).to be_present
        expect(item[:image]).to be_present if x.in?([0])
        expect(item[:description]).to be_present
        expect(item[:link]).to be_present
        expect(item[:date]).to be_present
        expect(item[:categories]).to be_present
        expect(item[:author]).to be_present
        expect(item[:author_link]).to be_present
      end
    end
  end

  shared_examples 'a cache with items' do |count: 4|
    let(:items) { Rails.cache.read(blog.key) }
    it_behaves_like 'items with expected fields', count: count
  end

  shared_examples 'a cache with excluded items' do |tag:|
    let(:items) { Rails.cache.read(blog.key) }
    it "does not contain items with excluded tag: #{tag}" do
      items.each do |item|
        expect(item[:categories].map(&:downcase)).not_to include(tag)
      end
    end
  end

  describe '#update_cache!' do
    it_behaves_like 'a cache without the key'

    context 'when cache is empty' do
      before do
        allow(Rollbar).to receive(:error)
        blog.update_cache!
      end

      context 'when request is successful' do
        let(:response) { response_success }

        it_behaves_like 'a cache with the key'
        it_behaves_like 'a cache with items', count: 4
        it_behaves_like 'a cache with excluded items', tag: 'Time sensitive'
      end

      context 'when request is successful but nothing is returned' do
        let(:response) { response_success_empty }

        it_behaves_like 'a cache without the key'

        it 'logs an error via Rollbar' do
          expect(Rollbar).to have_received(:error).with("No items extracted from blog feed: #{blog.url}")
        end
      end

      context 'when request is not successful' do
        let(:response) { response_error }

        it_behaves_like 'a cache without the key'

        it 'logs an error via Rollbar' do
          expect(Rollbar).to have_received(:error).with("Unable to fetch blog feed: #{blog.url}. Status: 500, body: Error 500")
        end
      end
    end

    context 'when cache is already populated' do
      before do
        Rails.cache.write(blog.key, [basic_item])
        allow(Rollbar).to receive(:error)
        blog.update_cache!
      end

      context 'when request is successful' do
        let(:response) { response_success }

        it_behaves_like 'a cache with the key'
        it_behaves_like 'a cache with items', count: 4
      end

      context 'when request is successful but nothing is returned' do
        let(:response) { response_success_empty }

        it_behaves_like 'a cache with the key'
        it_behaves_like 'a cache with items', count: 1

        it 'retains original items' do
          expect(blog.items).to eq([basic_item])
        end

        it 'logs an error via Rollbar' do
          expect(Rollbar).to have_received(:error).with("No items extracted from blog feed: #{blog.url}")
        end
      end

      context 'when request is not successful' do
        let(:response) { response_error }

        it_behaves_like 'a cache with the key'
        it_behaves_like 'a cache with items', count: 1

        it 'retains original items' do
          expect(blog.items).to eq([basic_item])
        end

        it 'logs an error via Rollbar' do
          expect(Rollbar).to have_received(:error).with("Unable to fetch blog feed: #{blog.url}. Status: 500, body: Error 500")
        end
      end
    end
  end

  describe '#items' do
    subject(:returned_items) { blog.items }

    context 'when there is nothing in the cache' do
      it_behaves_like 'a cache without the key'
      it 'returns an empty array' do
        expect(returned_items).to eq []
      end
    end

    context 'when the cache contains items' do
      before do
        blog.update_cache!
      end

      it_behaves_like 'a cache with items', count: 4
      it_behaves_like 'items with expected fields', count: 4 do
        let(:items) { returned_items }
      end
      it_behaves_like 'a cache with excluded items', tag: 'Time sensitive'
    end
  end

  describe '.new' do
    let(:max_retries) { 5 }
    let(:expected_retry_options) do
      BlogService::RETRY_OPTIONS.merge(max: max_retries)
    end

    let(:custom_url) { 'http://custom.url' }
    let(:faraday_connection) { instance_spy(Faraday::Connection) }

    before do
      allow(Faraday).to receive(:new).with(url: custom_url).and_yield(faraday_connection)
      BlogService.new(retries: max_retries, url: custom_url)
    end

    it 'sets retry options' do
      expect(faraday_connection).to have_received(:request).with(:retry, expected_retry_options)
    end
  end
end
