class HomeController < ApplicationController
  include VideoHelper

  # **** ALL ACTIONS IN THIS CONTROLLER ARE PUBLIC! ****
  skip_before_action :authenticate_user!
  before_action :redirect_if_logged_in, only: :index
  before_action :set_newsletters, only: [:index, :show]
  before_action :set_case_studies, only: [:index, :show, :for_management, :for_teachers]

  def index
  end

  def show
    render :index
  end

  def for_schools
    @school_count = School.visible.count
    @activities_count = ActivityType.active_and_not_custom.count
    @videos = videos
    @testimonial = [
      {
        quote: t('for_schools.quote_1.text_html'),
        by: 'Andrew Wishart',
        title: t('for_schools.quote_1.job_title'),
        location: 'Freshford Church School'
      }
    ].sample
  end

  def for_local_authorities
    @school_count = School.visible.count
    @testimonial = [
      {
        quote: t('for_local_authorities.quote_1.text_html'),
        by: 'Kremena Renwick',
        title: t('for_local_authorities.quote_1.job_title'),
        location: 'Highland Council'
      }
    ].sample
    @testimonial_saving = [
      {
        quote: t('for_local_authorities.quote_2.text_html'),
        by: 'Andrew Marriott',
        title: t('for_local_authorities.quote_2.job_title'),
        location: 'Federation of Bishop Sutton and Stanton Drew Primary Schools, Bath and NE Somerset'
      }
    ].sample
    @videos = videos
  end

  def for_multi_academy_trusts
    @school_count = School.visible.count
    @videos = videos
    @testimonial = [
      {
        quote: t('for_multi_academy_trusts.quote_1.text_html'),
        by: 'Warrick Barton',
        title: t('for_multi_academy_trusts.quote_1.job_title'),
        location: 'Pensford Primary School, Bath'
      }
    ].sample
    @testimonial_saving = [
      {
        quote: t('for_local_authorities.quote_2.text_html'),
        by: 'Andrew Marriott',
        title: t('for_local_authorities.quote_2.job_title'),
        location: 'Federation of Bishop Sutton and Stanton Drew Primary Schools, Bath and NE Somerset'
      }
    ].sample
  end

  def energy_audits
  end

  def education_workshops
  end

  def contact
  end

  def enrol
  end

  def enrol_our_school
  end

  def enrol_our_multi_academy_trust
  end

  def enrol_our_local_authority
  end

  def privacy_and_cookie_policy
  end

  def support_us
  end

  def terms_and_conditions
  end

  def attribution
  end

  def child_safeguarding_policy
  end

  def training
    @events = Events::ListEvents.new.perform
  end

  def user_guide_videos
    @videos = Video.order(:position)
  end

  def school_statistics
    @report = Schools::ReportingStatisticsService.new
  end

  def team
    @staff = TeamMember.staff.order(:position)
    @consultants = TeamMember.consultant.order(:position)
    @trustees = TeamMember.trustee.order(:position)
    @partners = Partner.order(:position)
  end

  private

  def videos
    [
      { title: 'What is Energy Sparks - an introduction', embed_url: 'https://www.youtube.com/embed/yPx8LCsK_rc' },
      { title: 'An introduction to Energy Sparks for eco teams', embed_url: 'https://www.youtube.com/embed/P9yJMOP9O9w' },
      { title: 'Saundersfoot CP School and Energy Sparks', embed_url: 'https://www.youtube.com/embed/Rg0znmJtr5s' },
    ]
  end

  def set_newsletters
    @newsletters = Newsletter.order(published_on: :desc).limit(3)
  end

  def set_case_studies
    @all_case_studies_count = CaseStudy.count
    @case_studies = CaseStudy.order(position: :asc).limit(3)
  end

  def redirect_if_logged_in
    if user_signed_in?
      if current_user.school
        redirect_to redirect_with_school_path
      elsif current_user.school_onboarding? && current_user.school_onboardings.any?
        redirect_to onboarding_path(current_user.school_onboardings.last)
      elsif current_user.school_group && can?(:show, current_user.school_group)
        redirect_to school_group_path(current_user.school_group)
      else
        redirect_to schools_path
      end
    end
  end

  def redirect_with_school_path
    if current_user.school.visible?
      school_path(current_user.school)
    else
      school_inactive_path(current_user.school)
    end
  end
end
