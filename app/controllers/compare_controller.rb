class CompareController < ApplicationController
  before_action :header_fix_enabled
  skip_before_action :authenticate_user!

  # before_action :latest_benchmark_run, only: [:results]

  # filters
  def group
  end

  def categories
  end

  def groups
  end

  # pick benchmark
  def benchmark
  end

  # display results
  def results
  end
end
