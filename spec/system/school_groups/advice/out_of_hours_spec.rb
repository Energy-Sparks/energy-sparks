require 'rails_helper'

RSpec.shared_examples_for 'a group out of hours advice page' do
end

describe 'School group out of hours pages' do
  context 'with electricity out of hours page' do
    it_behaves_like 'a group out of hours advice page' do
      let(:advice_page_key) { :electricity_out_of_hours }
    end
  end

  context 'with gas out of hours page' do
    it_behaves_like 'a group out of hours advice page' do
      let(:advice_page_key) { :gas_out_of_hours }
    end
  end
end
