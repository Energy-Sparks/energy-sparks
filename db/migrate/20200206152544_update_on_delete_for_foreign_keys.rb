class UpdateOnDeleteForForeignKeys < ActiveRecord::Migration[6.0]
  CHANGES = {
    %i[activities schools] => :cascade,
    %i[activities activity_categories] => :restrict,
    %i[activities activity_types] => :restrict,
    %i[activity_type_suggestions activity_types] => :cascade,
    %i[alert_subscription_events alerts] => :cascade,
    %i[amr_validated_readings meters] => :cascade,
    %i[calendar_events academic_years] => :restrict,
    %i[calendar_events calendar_event_types] => :restrict,
    %i[calendar_events calendars] => :cascade,
    %i[meters schools] => :cascade,
    %i[schools calendars] => :restrict,
    %i[schools school_groups] => :restrict,
    %i[simulations schools] => :cascade,
    %i[simulations users] => :nullify
  }.freeze

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
