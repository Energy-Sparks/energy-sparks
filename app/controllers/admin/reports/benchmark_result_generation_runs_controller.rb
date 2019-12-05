module Admin
  module Reports
    class BenchmarkResultGenerationRunsController < AdminController
      def index
        @benchmark_result_generation_runs = BenchmarkResultGenerationRun.includes(:benchmark_results, :benchmark_result_errors).order(created_at: :desc).all
      end

      def show
        @benchmark_result_generation_run = BenchmarkResultGenerationRun.includes(:benchmark_results, :benchmark_result_errors).find(params[:id])
      end
    end
  end
end
