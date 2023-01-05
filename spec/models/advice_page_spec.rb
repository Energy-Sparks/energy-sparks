require 'rails_helper'

describe AdvicePage do

  it 'rejects duplicate keys' do
    AdvicePage.create(key: 'same')
    expect {
      AdvicePage.create(key: 'same')
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end

end
