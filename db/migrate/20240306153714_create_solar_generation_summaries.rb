class CreateSolarGenerationSummaries < ActiveRecord::Migration[6.1]
  def change
    create_view :solar_generation_summaries
  end
end
