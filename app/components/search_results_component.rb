class SearchResultsComponent < ApplicationComponent
  attr_reader :anchor

  renders_one :title
  renders_one :subtitle
  renders_many :results

  def initialize(anchor: nil, **_kwargs)
    @anchor = anchor
  end
end
