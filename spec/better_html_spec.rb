# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BetterHtml', :aggregate_failures do
  it 'does assert that .html.erb templates are parseable' do
    erb_glob = Rails.root.join(
      'app/{views,components}/**/{*.htm,*.html,*.htm.erb,*.html.erb,*.html+*.erb}'
    )
    Dir[erb_glob].each do |filename|
      data = File.read(filename)
      expect do
        begin
          BetterHtml::BetterErb::ErubiImplementation.new(data, filename:).validate!
        rescue
          p filename
          raise
        end
      end.not_to raise_exception
    end
  end
end
