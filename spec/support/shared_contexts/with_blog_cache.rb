RSpec.shared_context('with blog cache') do
  include_context 'with cache'

  let(:fixture_path) { File.expand_path('spec/fixtures/files/blog-feed.xml', Dir.pwd) }
  let(:blog_xml) { File.read(fixture_path) }

  let(:response) do
    instance_double(Faraday::Response, body: blog_xml, status: 200).tap do |r|
      allow(r).to receive(:success?).and_return(true)
    end
  end

  let!(:blog) { BlogService.new }

  before do
    allow(blog.instance_variable_get(:@connection)).to receive(:get).and_return(response)
  end

  before do
    blog.update_cache!
  end
end
