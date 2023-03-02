class CompareController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :header_fix_enabled

  before_action :get_school_group
  before_action :redirect_unless_school_group, only: [:group]

  # before_action :latest_benchmark_run, only: [:results]

  # filters
  def group
    params[:school_types] ||= School.school_types.keys
  end

  def categories
  end

  def groups
  end

  # pick benchmark
  def benchmarks
  end

  # display results
  def results
  end

  private

  def get_school_group
    @school_group = current_user.try(:default_school_group)
  end

  def redirect_unless_school_group
    redirect_to categories_compare_url unless @school_group
  end
end
