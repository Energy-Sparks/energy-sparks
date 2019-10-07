class AddContentVersionToSubscriptionEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :alert_subscription_events, :alert_type_rating_content_version, foreign_key: {on_delete: :cascade}, index: {name: 'alert_sub_content_v_id'}
  end
end
