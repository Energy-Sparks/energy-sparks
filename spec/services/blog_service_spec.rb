require 'rails_helper'

RSpec.describe BlogService, type: :service do
  include_context 'with cache'

  let(:fixture_path) { File.expand_path('spec/fixtures/files/blog-feed.xml', Dir.pwd) }
  let(:blog_xml) { File.read(fixture_path) }

  let(:response) do
    instance_double(Net::HTTPSuccess, body: blog_xml).tap do |response|
      allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    end
  end

  before do
    allow(Net::HTTP).to receive(:get_response).and_return(response)
  end

  shared_examples 'an empty cache' do
    it { expect(Rails.cache.exist?(blog.key)).to be false }
  end

  shared_examples 'a cache with blog key' do
    it { expect(Rails.cache.exist?(blog.key)).to be true }
  end

  shared_examples 'a cache with blog fields' do
    it 'contains the blog fields' do
      (0..4).each do |x|
        item = blog.cached_feed[:items][x]

        expect(item[:title]).to be_present
        expect(item[:image]).to be_present if x.in?([0, 1])
        expect(item[:description]).to be_present
        expect(item[:link]).to be_present
        expect(item[:date]).to be_present
        expect(item[:categories]).to be_present
        expect(item[:author]).to be_present
      end
    end
  end

  describe '#cache_feed!' do
    let(:blog) { BlogService.new(inline_fetch: false) }

    it_behaves_like 'an empty cache'

    context 'when cache is empty' do
      before do
        freeze_time
        blog.cache_feed!
      end

      it { expect(blog.cached_feed[:timestamp]).to eq(Time.zone.now) }
      it { expect(blog.cached_feed[:items].count).to be 5 }

      it_behaves_like 'a cache with blog key'
      it_behaves_like 'a cache with blog fields'
    end

    context 'when cache is present' do
      before do
        freeze_time
        blog.cache_feed!
      end

      let!(:cached_time) { blog.cached_feed[:timestamp] }

      context 'when it is 10 minutes later' do
        before do
          travel 10.minutes
          blog.cache_feed!
        end

        it_behaves_like 'a cache with blog fields'

        it 'does not update the cache' do
          expect(blog.cached_feed[:timestamp]).to eq(cached_time)
        end
      end

      context 'when it is over an hour later' do
        before do
          travel 61.minutes
          blog.cache_feed!
        end

        it_behaves_like 'a cache with blog fields'

        it 'updates the cache' do
          expect(blog.cached_feed[:timestamp]).not_to eq(cached_time)
        end
      end

      context 'when it is over two hours later' do
        before do
          travel 121.minutes
          blog.cache_feed!
        end

        it_behaves_like 'a cache with blog fields'

        it 'updates the cache' do
          expect(blog.cached_feed[:timestamp]).not_to eq(cached_time)
        end
      end

      context 'when response is not a success' do
        let(:error_response) do
          instance_double(Net::HTTPResponse, code: '500', message: 'Internal Server Error')
        end

        before do
          allow(Net::HTTP).to receive(:get_response).and_return(error_response)
          allow(Rollbar).to receive(:error)
        end

        context 'when it is over 2 hours later (cache warning error raised)' do
          before do
            travel 122.minutes
            blog.cache_feed!
          end

          it 'does not update the cache' do
            expect(blog.cached_feed[:timestamp]).to eq(cached_time)
          end

          it 'logs an error via Rollbar' do
            expect(Rollbar).to have_received(:error).with("Blog #{blog.url} cache is over #{BlogService::CACHE_WARNING_PERIOD.seconds.in_hours} out of date: 500 Internal Server Error")
          end
        end

        context 'when it is less than 2 hours later (no error raised)' do
          before do
            allow(Rollbar).to receive(:error)

            travel 65.minutes
            blog.cache_feed!
          end

          it 'does not update the cache' do
            expect(blog.cached_feed[:timestamp]).to eq(cached_time)
          end

          it 'does not log error via Rollbar' do
            expect(Rollbar).not_to have_received(:error)
          end
        end

        context 'with retries > 0 and it is over 2 hours later (cache warning raised)' do
          let(:blog) { BlogService.new(inline_fetch: false, retries: 2) }

          before do
            allow(Rollbar).to receive(:error)

            travel 122.minutes
            blog.cache_feed!
          end

          it 'does not update the cache' do
            expect(blog.cached_feed[:timestamp]).to eq(cached_time)
          end

          it 'retries' do
            # 4 times - once for test setup, once for first try, twice for retries
            expect(Net::HTTP).to have_received(:get_response).exactly(4).times
          end

          it 'logs one error via Rollbar' do
            expect(Rollbar).to have_received(:error).once.with("Blog #{blog.url} cache is over #{BlogService::CACHE_WARNING_PERIOD.seconds.in_hours} out of date: 500 Internal Server Error")
          end
        end
      end
    end
  end

  describe '#items' do
    subject(:blog) { BlogService.new(inline_fetch: true) }

    it_behaves_like 'an empty cache'

    context 'when the cache is empty' do
      before do
        blog.items
      end

      it_behaves_like 'a cache with blog key'
      it_behaves_like 'a cache with blog fields'
    end
  end
end
