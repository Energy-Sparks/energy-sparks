class UpdateOnDeleteForForeignKeys < ActiveRecord::Migration[6.0]

  CHANGES = {
    [:activities, :schools] => :cascade,
    [:activities, :activity_categories] => :restrict,
    [:activities, :activity_types] => :restrict,
    [:activity_type_suggestions, :activity_types] => :cascade,
    [:alert_subscription_events, :alerts] => :cascade,
    [:amr_validated_readings, :meters] => :cascade,
    [:calendar_events, :academic_years] => :restrict,
    [:calendar_events, :calendar_event_types] => :restrict,
    [:calendar_events, :calendars] => :cascade,
    [:schools, :calendars] => :restrict,
    [:schools, :school_groups] => :restrict,
    [:simulations, :schools] => :cascade,
    [:simulations, :users] => :nullify,
  }

  def up
    # remove and re-add with on_delete
    CHANGES.each do |(from, to), on_delete|
      remove_foreign_key from, to
      add_foreign_key from, to, on_delete: on_delete
    end
  end

  def down
    # remove and re-add without on_delete
    CHANGES.each do |(from, to), _on_delete|
      remove_foreign_key from, to
      add_foreign_key from, to
    end
  end
end
