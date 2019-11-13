require 'rails_helper'

describe Alerts::Adapters::Report do
  describe 'displayable?' do
    it{ expect( Alerts::Adapters::Report.new(valid: true, rating: 10, enough_data: :enough, relevance: :relevant, alert_type: nil, asof_date: nil)).to be_displayable }

    it{ expect( Alerts::Adapters::Report.new(valid: false, rating: 10, enough_data: :enough, relevance: :relevant, alert_type: nil, asof_date: nil)).to_not be_displayable }

    it{ expect( Alerts::Adapters::Report.new(valid: true, rating: nil, enough_data: :enough, relevance: :relevant, alert_type: nil, asof_date: nil)).to_not be_displayable }

    it{ expect( Alerts::Adapters::Report.new(valid: true, rating: 10, enough_data: :not_enough, relevance: :relevant, alert_type: nil, asof_date: nil)).to_not be_displayable }
    it{ expect( Alerts::Adapters::Report.new(valid: true, rating: 10, enough_data: nil, relevance: :relevant, alert_type: nil, asof_date: nil)).to_not be_displayable }

    it{ expect( Alerts::Adapters::Report.new(valid: true, rating: nil, enough_data: :enough, relevance: :not_relevant, alert_type: nil, asof_date: nil)).to_not be_displayable }
    it{ expect( Alerts::Adapters::Report.new(valid: true, rating: nil, enough_data: :enough, relevance: nil, alert_type: nil, asof_date: nil)).to_not be_displayable }
  end
end
