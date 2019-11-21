module Admin
  class BenchmarkResultGenerationRunsController < AdminController
    def index
      @benchmark_result_generation_runs = BenchmarkResultGenerationRun.all.order(created_at: :desc)
    end

    def show
    end
  end
end
