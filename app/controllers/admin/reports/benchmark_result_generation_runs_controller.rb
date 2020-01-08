module Admin
  module Reports
    class BenchmarkResultGenerationRunsController < AdminController
      def index
        @benchmark_result_generation_runs = BenchmarkResultGenerationRun.order(created_at: :desc)
      end

      def show
        @benchmark_result_generation_run = BenchmarkResultGenerationRun.includes(:benchmark_results, :benchmark_result_errors).find(params[:id])
      end
    end
  end
end
