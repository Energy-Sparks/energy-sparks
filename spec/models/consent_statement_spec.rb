require 'rails_helper'

describe 'ConsentStatement' do

  let!(:consent_statement) { ConsentStatement.create!( title: 'First consent statement', content: 'You may use my data..', current: true) }

  it 'can only have one current' do
    expect {
      ConsentStatement.create!( title: 'Second consent statement', content: 'You may still use my data..', current: true)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
