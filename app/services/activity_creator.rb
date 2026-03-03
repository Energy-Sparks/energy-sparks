# frozen_string_literal: true

class ActivityCreator
  def initialize(activity, user)
    @activity = activity
    @user = user
  end

  def process
    @activity.activity_category = @activity.activity_type.activity_category if @activity.activity_type
    @activity.created_by = @user

    if @activity.save
      process_programmes if started_active_programmes.any?
      create_activity_observation
      create_completed_audit_activities_observation
    end
    @activity.persisted?
  end

  private

  def process_programmes
    started_active_programmes.each do |programme|
      add_programme_activity(programme)
      programme.complete! if programme.all_activities_complete?
    end
  end

  def create_completed_audit_activities_observation
    @activity.school.audits.with_activity_types.each(&:create_activities_completed_observation!)
  end

  def create_activity_observation
    Observation.create!(
      school: @activity.school,
      observation_type: :activity,
      activity: @activity,
      at: @activity.happened_on,
      created_by: @user
    )
  end

  def started_active_programmes
    @activity.school.programmes.started.active
  end

  def add_programme_activity(programme)
    # A ProgrammeType is a set of themed ActivityTypes, e.g. reduce your gas usage. Because an ActivityType
    # can be in multiple ProgrammeTypes, there is a many-many association ProgrameTypeActivityType that links
    # the two models.
    #
    # When a school signs up to complete a ProgrammeType we record that as a Programme. When they complete an
    # ActivityType we record that as a new Activity.
    #
    # To track progress against completing the ProgrammeType we should only be associating the school's Programme
    # with those Activities that are for ActivityTypes that are part of the programme. So we only create
    # ProgrammeActivity records in that case.
    return unless programme.programme_type.activity_types.pluck(:id).include?(@activity.activity_type.id)

    # Create programme_activity for this programme, associated with programme, activity_type and activity
    # but not if there already is a record for this activity type, so just recording the first instance
    if programme_activities(programme).empty?
      programme.programme_activities.create!(activity_type: @activity.activity_type, activity: @activity)
    else
      # If programme activity already exists for this type, set the new activity
      programme_activities(programme).last.update(activity: @activity)
    end
  end

  def programme_activities(programme)
    programme.programme_activities.where(activity_type: @activity.activity_type)
  end
end
