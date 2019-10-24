# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://energysparks.uk"

if ENV.key?('GENERATE_SITEMAP')
  SitemapGenerator::Sitemap.create do

    # Home controller stuff
    add root_path
    add for_teachers_path
    add for_pupils_path
    add for_management_path
    add for_teachers_path
    add home_page_path
    add contact_path
    add enrol_path
    add datasets_path
    add team_path
    add getting_started_path
    add scoring_path
    add privacy_and_cookie_policy_path

    add schools_path
    add activity_types_path

    ActivityType.find_each do |activity_type|
      add activity_type_path(activity_type)
    end

    add scoreboards_path

    Scoreboard.find_each do |scoreboard|
      add scoreboard_path(scoreboard)
    end

    School.find_each do |school|
      add school_path(school)
      add school_activities_path(school)
      add school_programme_types_path(school)
      add school_timeline_path(school)
    end
  end
end
