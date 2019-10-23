class AddPupilAnalysisToSchoolConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column :configurations, :pupil_analysis_charts, :json, default: {}, null: false
  end
end
