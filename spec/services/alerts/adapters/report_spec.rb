require 'rails_helper'

describe Alerts::Adapters::Report do
  describe 'displayable?' do
    it{ expect( Alerts::Adapters::Report.new(valid: true, status: :good, rating: 10, enough_data: :enough)).to be_displayable }

    it{ expect( Alerts::Adapters::Report.new(valid: false, status: :good, rating: 10, enough_data: :enough)).to_not be_displayable }

    it{ expect( Alerts::Adapters::Report.new(valid: true, status: :failed, rating: 10, enough_data: :enough)).to_not be_displayable }
    it{ expect( Alerts::Adapters::Report.new(valid: true, status: nil, rating: 10, enough_data: :enough)).to_not be_displayable }

    it{ expect( Alerts::Adapters::Report.new(valid: true, status: :good, rating: nil, enough_data: :enough)).to_not be_displayable }

    it{ expect( Alerts::Adapters::Report.new(valid: true, status: :good, rating: 10, enough_data: :not_enough)).to_not be_displayable }
    it{ expect( Alerts::Adapters::Report.new(valid: true, status: :good, rating: 10, enough_data: nil)).to_not be_displayable }
  end
end
