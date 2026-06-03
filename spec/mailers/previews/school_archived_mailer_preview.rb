class SchoolArchivedMailerPreview < ActionMailer::Preview
  def self.archived_params
    { school: School.active.sample.id }
  end

  def archived
    school = School.find(params[:school])
    users = school.all_adult_school_users
    SchoolArchivedMailer.with(users:, school:).archived
  end
end
