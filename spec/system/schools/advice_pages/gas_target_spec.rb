# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'gas target advice page' do
  it_behaves_like 'target advice page' do
    let(:fuel_type) { :gas }
  end
end
