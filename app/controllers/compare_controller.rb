class CompareController < ApplicationController
  before_action :header_fix_enabled
  skip_before_action :authenticate_user!

  before_action :get_school_group

  # before_action :latest_benchmark_run, only: [:results]

  # filters

  def index
    params[:school_types] ||= School.school_types.keys
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
end
