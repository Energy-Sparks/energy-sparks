# rubocop:disable Metrics/BlockLength
namespace :after_party do
  desc 'Deployment task: group_admins_with_cluster_schools'
  task group_admins_with_cluster_schools: :environment do
    puts "Running deploy task 'group_admins_with_cluster_schools'"

    # Find group admins who have also been manually linked to schools, e.g. were
    # originally school admins. Remove all those associations as they're unnecessary
    # but are impacting engagement reporting. Also remove any direct school links.
    #
    # 32 users
    User.group_admin.joins(:cluster_schools_users).distinct.each do |group_admin|
      group_admin.cluster_schools.destroy_all
      group_admin.update(school: nil)
    end

    # Find users who are school admins but are also linked to school groups, e.g. were
    # originally group admins. Promote those linked to all schools to be group admins
    #
    # 1 user
    User.school_admin.where.not(school_group: nil).find_each do |school_admin|
      if school_admin.cluster_schools.sort == school_admin.school_group.schools.sort
        school_admin.update(role: :group_admin)
        school_admin.update(school: nil)
      end
    end

    # Find school admins who are linked via cluster_schools to every school in their
    # group. They should be promoted to be group admins
    to_promote = Set.new
    User.school_admin.joins(:cluster_schools_users).find_each do |school_admin|
      # Add to the list for promotion if
      # - they are linked to multiple schools
      # - they are only linked to schools in a single group
      # - the group is a local authority or MAT and not a general grouping we made
      # - they are linked to all the schools in that group
      multiple_schools = school_admin.cluster_schools.count > 1
      single_group_cluster = school_admin.cluster_schools.map(&:school_group).uniq.count == 1
      single_group = school_admin.cluster_schools.first.school_group
      organisation_group = single_group.group_type != 'general'
      all_schools_in_group = single_group.schools.sort == school_admin.cluster_schools.sort

      to_promote << school_admin if multiple_schools && single_group_cluster && organisation_group && all_schools_in_group
    end

    # About 31 users currently
    to_promote.each do |school_admin|
      # AR callback on model will remove the cluster schools
      school_admin.update(
        role: :group_admin,
        school: nil,
        school_group: school_admin.cluster_schools.first.school_group
      )
    end

    # Remove school group association from following individual school_admins who don't meet the
    # above criteria. These have been manually checked
    [6868, 5889, 5890].each do |school_admin_id|
      User.find_by_id(school_admin_id)&.update(school_group: nil)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
# rubocop:enable Metrics/BlockLength
