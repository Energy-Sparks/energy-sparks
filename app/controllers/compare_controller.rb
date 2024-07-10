class CompareController < ApplicationController
  include UserTypeSpecific
  skip_before_action :authenticate_user!

  before_action :filter

  before_action :set_school_groups, only: [:index]
  helper_method :index_params

  # filters
  def index
    # Count is of all available benchmarks for guest users only
    @benchmark_count = Comparison::Report.where(public: true, disabled: false).count
  end

  # Redirect old urls
  # FIXME: what about if we dont have this report any more?
  def show
    redirect_to controller: "comparisons/#{filter.delete(:benchmark)}", **filter
  end

  private

  def filter
    @filter ||=
      params.permit(:search, :benchmark, :country, :school_type, :funder, school_group_ids: [], school_types: [])
        .with_defaults(school_group_ids: [], school_types: School.school_types.keys)
        .to_hash.symbolize_keys
  end

  def index_params
    filter.merge(anchor: filter[:search])
  end

  # Set list of school groups visible to this user
  def set_school_groups
    @school_groups = ComparisonService.new(current_user).list_school_groups.select(&:has_visible_schools?)
  end
end
