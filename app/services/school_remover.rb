class SchoolRemover
  class Error < StandardError; end

  def initialize(school, archive: false)
    @school = school
    @archive = archive
  end

  def school_ready?
    !@school.visible?
  end

  def meters_ready?
    @school.meters.active.empty?
  end

  def users_ready?
    # Requires all school users are access locked except those linked to another school
    return true if @school.users.all?(&:access_locked?)

    all_unlocked_users_are_linked_to_other_schools?
  end

  def can_remove_school?
    meters_ready? && users_ready? && school_ready?
  end

  def remove_school!
    raise SchoolRemover::Error.new('Cannot remove school while it is still visible') if @school.visible?
    @school.transaction do
      if @school.update!(active: false, process_data: false, removal_date: removal_date, archived_date: archived_date)
        delete_school_issues
      end
    end
  end

  def reenable_school!
    raise SchoolRemover::Error.new('Cannot reenable an active school') if @school.active?
    @school.transaction do
      @school.update(active: true, removal_date: nil, archived_date: nil)
    end
  end

  def remove_users!
    raise SchoolRemover::Error.new('Cannot remove users while school is still visible') if @school.visible?

    @school.transaction do
      @school.users.each do |user|
        next if user.has_other_schools? && @archive

        if user.has_other_schools?
          user.remove_school(@school)
        else
          # Lock account if user is linked to only this school
          user.contacts.for_school(@school).first&.destroy unless @archive
          user.lock_access!(send_instructions: false)
        end
      end
    end
  end

  def remove_meters!
    raise SchoolRemover::Error.new('Cannot remove meters while school is still visible') if @school.visible?
    @school.transaction do
      @school.meters.each do |meter|
        remove_meter(meter)
      end
    end
  end

  private

  def all_unlocked_users_are_linked_to_other_schools?
    # Return false if none of the unlocked users have other schools
    return false if unlocked_users_linked_to_another_school_ids.empty?

    # Confirm *all* unlocked users have other schools
    (unlocked_user_ids - unlocked_users_linked_to_another_school_ids).empty?
  end

  def unlocked_users_linked_to_another_school_ids
    @unlocked_users_linked_to_another_school_ids ||= unlocked_users_linked_to_another_school.pluck(:id)
  end

  def unlocked_users_linked_to_another_school
    User.find_school_users_linked_to_other_schools(school_id: @school.id, user_ids: unlocked_user_ids)
  end

  def unlocked_user_ids
    @unlocked_user_ids ||= @school.users.reject(&:access_locked?).pluck(:id)
  end

  def delete_school_issues
    return if @archive

    IssueMeter.where(meter: @school.meters).delete_all
    @school.issues.delete_all
  end

  def removal_date
    @archive ? nil : Time.zone.today
  end

  def archived_date
    @archive ? Time.zone.today : nil
  end

  def remove_meter(meter)
    service = MeterManagement.new(meter)
    service.deactivate_meter!
    service.remove_data!(archive: @archive)
  end
end
