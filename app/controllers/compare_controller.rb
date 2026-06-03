class CompareController < ApplicationController
  include UserTypeSpecific
  skip_before_action :authenticate_user!

  before_action :filter

  before_action :set_school_groups, only: [:index]
  before_action :set_included_schools, only: [:benchmarks]
  helper_method :index_params

  # filters
  def index
    # Count is of all available benchmarks for guest users only
    @benchmark_count = Comparison::Report.where(public: true, disabled: false).count
  end

  # pick benchmark
  def benchmarks
    if @included_schools.empty?
      render :no_schools and return
    end
  end

  # Redirect old urls
  # TODO: what about if we dont have this report any more?
  def show
    redirect_to controller: "comparisons/#{filter.delete(:benchmark)}", **filter
  end

  private

  def set_included_schools
    @included_schools = included_schools
  end

  def included_schools
    # wonder if this can be replaced by a use of the scope accessible_by(current_ability)
    include_invisible = can? :show, :all_schools

    school_params = filter.slice(:school_group_ids, :school_types, :school_type, :country, :funder).merge(include_invisible: include_invisible)

    schools = SchoolFilter.new(**school_params).filter.to_a
    schools = schools.select {|s| can?(:show, s) } unless include_invisible
    schools
  end

  def filter
    @filter ||=
      params.permit(:search, :benchmark, :country, :school_type, :funder, :group, school_group_ids: [], school_types: [])
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
