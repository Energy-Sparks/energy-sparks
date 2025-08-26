# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'storage heater target advice page' do
  it_behaves_like 'target advice page' do
    let(:fuel_type) { :storage_heater }
  end
end
