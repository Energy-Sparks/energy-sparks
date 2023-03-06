class CompareController < ApplicationController
  include UserTypeSpecific

  before_action :header_fix_enabled
  skip_before_action :authenticate_user!

  before_action :get_school_group
  before_action :latest_benchmark_run
  before_action :content_manager
  before_action :benchmark_groups, only: [:benchmarks]

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

  def latest_benchmark_run
    @latest_benchmark_run ||= BenchmarkResultGenerationRun.latest
  end

  def content_manager
    @content_manager ||= Benchmarking::BenchmarkContentManager.new(@latest_benchmark_run.run_date)
  end

  def benchmark_groups
    @benchmark_groups = @content_manager.structured_pages(school_ids: nil, filter: nil, user_type: user_type_hash)
  end

  def get_school_group
    @school_group = current_user.try(:default_school_group)
  end
end
