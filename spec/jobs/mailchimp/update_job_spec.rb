require 'rails_helper'

describe Mailchimp::UpdateJob do
  subject(:job) { described_class.new }

  let!(:model) { create(:user) }

  it 'generates updates' do
    expect { job.perform(model) }.to change(Mailchimp::Update, :count)
  end
end
