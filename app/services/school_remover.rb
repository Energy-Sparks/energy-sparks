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
    # Requires all users are access locked except those users linked to another school
    return true if @school.users.all?(&:access_locked?)
    return true if unlocked_users_linked_to_another_school.any?

    false
  end

  def can_remove_school?
    meters_ready? && users_ready? && school_ready?
  end

  def remove_school!
    raise SchoolRemover::Error.new('Cannot remove school while it is still visible') if @school.visible?
    @school.transaction do
      @school.update(active: false, process_data: false, removal_date: removal_date)
    end
  end

  def reenable_school!
    raise SchoolRemover::Error.new('Cannot reenable an active school') if @school.active?
    @school.transaction do
      @school.update(active: true, removal_date: nil)
    end
  end

  def remove_users!
    raise SchoolRemover::Error.new('Cannot remove users while school is still visible') if @school.visible?

    @school.transaction do
      @school.users.each do |user|
        if user.has_other_schools?
          # Don’t remove users from schools when they are archived so the links are retained
          user.remove_school(@school) unless @archive

        else
          user.contacts.for_school(@school).first&.destroy unless @archive
          # Lock account if user is linked to only this school
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

  def unlocked_users_linked_to_another_school
    unlocked_user_ids = @school.users.reject(&:access_locked?).pluck(:id)
    query = <<-SQL.squish
      SELECT *
      FROM cluster_schools_users
      WHERE school_id != #{@school.id}
      AND user_id IN (#{unlocked_user_ids.join(',')});
    SQL

    ActiveRecord::Base.connection.execute(query)
  end

  def removal_date
    @archive ? nil : Time.zone.today
  end

  def remove_meter(meter)
    service = MeterManagement.new(meter)
    service.deactivate_meter!
    service.remove_data!(archive: @archive)
  end
end
