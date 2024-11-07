class SearchResultsComponent < ApplicationComponent
  renders_one :title
  renders_one :subtitle
  renders_many :results
end
