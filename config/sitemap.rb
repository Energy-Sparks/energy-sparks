# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://energysparks.uk"

if ENV.key?('GENERATE_SITEMAP')
  SitemapGenerator::Sitemap.create do

    # Home controller stuff
    add root_path

    add home_page_path
    add contact_path
    add enrol_path
    add datasets_path
    add attribution_path
    add team_path
    add privacy_and_cookie_policy_path
    add terms_and_conditions_path
    add case_studies_path
    add newsletters_path
    add user_guide_youtube_path
    add resources_path
    add jobs_path

    add schools_path
    add scoreboards_path
    add programme_types_path
    add activity_categories_path

    ActivityCategory.all.find_each do |activity_category|
      add activity_category_path(activity_category)
    end

    ActivityType.active.find_each do |activity_type|
      add activity_type_path(activity_type)
    end

    ProgrammeType.active.find_each do |programme_type|
      add programme_type_path(programme_type)
    end

    Scoreboard.is_public.find_each do |scoreboard|
      add scoreboard_path(scoreboard)
    end

    School.visible.find_each do |school|
      add school_path(school)
      add school_activities_path(school)
      add school_timeline_path(school)
    end
  end
end
