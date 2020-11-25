
require 'rails_helper'

describe MailchimpApi do

  let(:lists_api) { double(MailchimpMarketing::ListsApi) }
  let(:client) { double(MailchimpMarketing::Client, lists: lists_api) }
  let(:api) { MailchimpApi.new(client) }

  let!(:lists_data) { YAML.load(File.read('spec/fixtures/mailchimp/lists.yml')) }
  let!(:categories_data) { YAML.load(File.read('spec/fixtures/mailchimp/categories.yml')) }
  let!(:interests_data) { YAML.load(File.read('spec/fixtures/mailchimp/interests.yml')) }

  before do
    allow(lists_api).to receive(:get_all_lists).and_return(lists_data)
    allow(lists_api).to receive(:get_list_interest_categories).and_return(categories_data)
    allow(lists_api).to receive(:list_interest_category_interests).and_return(interests_data)
  end

  it 'return lists' do
    lists = api.lists
    expect(lists.count).to eq(1)
    expect(lists.first.id).to eq('ed205db324')
  end

  it 'returns categories' do
    categories = api.categories('123')
    expect(categories.count).to eq(2)
    expect(categories.first.id).to eq('908f880968')
    expect(categories.first.title).to eq('User type')
    expect(categories.last.id).to eq('fc30f60658')
    expect(categories.last.title).to eq('Local Authority area or school group')
  end

  it 'returns interests' do
    interests = api.interests('123', '456')
    expect(interests.count).to eq(8)
    expect(interests.first.id).to eq('be32b53ee1')
    expect(interests.first.name).to eq('Council /MAT')
    expect(interests.last.id).to eq('85bb2d8115')
    expect(interests.last.name).to eq('Building/ Site Manager or Caretaker')
  end

end
