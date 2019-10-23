class AddWeightingFieldsToAlertContent < ActiveRecord::Migration[6.0]
  def change
    [:email, :sms, :management_dashboard_alert, :management_priorities, :pupil_dashboard_alert, :public_dashboard_alert, :teacher_dashboard_alert, :find_out_more].each do |alert_functionality|
      add_column :alert_type_rating_content_versions, :"#{alert_functionality}_weighting", :float, default: 5.0
    end
  end
end
