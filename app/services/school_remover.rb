class SchoolRemover
  class Error < StandardError; end

  def initialize(school)
    @school = school
  end

  def school_ready?
    !@school.visible?
  end

  def meters_ready?
    @school.meters.active.empty?
  end

  def users_ready?
    @school.users.all?(&:access_locked?)
  end

  def can_remove_school?
    meters_ready? && users_ready? && school_ready?
  end

  def remove_school!
    raise SchoolRemover::Error.new('Cannot remove school while it is still visible') if @school.visible?
    @school.transaction do
      @school.update(active: false, process_data: false, removal_date: Time.zone.today)
    end
  end

  def remove_users!
    raise SchoolRemover::Error.new('Cannot remove meters while school is still visible') if @school.visible?
    @school.transaction do
      @school.users.each do |user|
        # IF USER NOT GROUP USER WITH OTHER SCHOOLS....
        user.lock_access!(send_instructions: false)
        user.update(email: 'removed-' + SecureRandom.alphanumeric + '@example.com')
        # END
      end
    end
  end

  def remove_meters!
    raise SchoolRemover::Error.new('Cannot remove meters while school is still visible') if @school.visible?
    @school.transaction do
      @school.meters.each do |meter|
        service = MeterManagement.new(meter)
        service.deactivate_meter!
        service.remove_data!
      end
    end
  end
end
