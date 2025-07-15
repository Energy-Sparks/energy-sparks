class HomeController < ApplicationController
  include VideoHelper
  include ApplicationHelper

  # **** ALL ACTIONS IN THIS CONTROLLER ARE PUBLIC! ****
  skip_before_action :authenticate_user!
  before_action :redirect_if_logged_in, only: :index
  before_action :set_blog_service, only: [:index, :show]
  before_action :set_marketing_case_studies, only: [:for_local_authorities, :for_multi_academy_trusts, :for_schools]

  def index
  end

  def show
    render :index
  end

  def for_schools
    redirect_to find_out_more_campaigns_path(utm_params_for_redirect)
  end

  def for_local_authorities
    redirect_to find_out_more_campaigns_path(utm_params_for_redirect)
  end

  def for_multi_academy_trusts
    redirect_to find_out_more_campaigns_path(utm_params_for_redirect)
  end

  def energy_audits
  end

  def education_workshops
  end

  def product
  end

  def contact
  end

  def enrol_our_school
  end

  def enrol_our_multi_academy_trust
    redirect_to 'https://forms.gle/K1XHu3GAUWJkNwFi6'
  end

  def enrol_our_local_authority
    redirect_to 'https://forms.gle/v78XueeSdfggcyhz8'
  end

  def cookies
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

  def funders
    @school_count = School.visible.count
    @partners = Partner.order(:position)
  end

  def training
    list_events = Events::ListEvents.new
    @events = list_events.events

    unless Flipper.enabled?(:training_page, current_user)
      @show_images = list_events.events_without_images.none? || (params[:show_images] && current_user&.admin?)
    end
  end

  def user_guide_videos
    @videos = Video.order(:position)
  end

  def school_statistics
    @report = find_school_statistics
  end

  def school_statistics_key_data
    @school_groups = SchoolGroup.with_active_schools.is_public.order(:name)
  end

  def team
    @staff = TeamMember.staff.order(:position)
    @consultants = TeamMember.consultant.order(:position)
    @trustees = TeamMember.trustee.order(:position)
  end

  private

  def find_school_statistics
    Schools::ReportingStatisticsService.new
  end

  def videos
    [
      { title: 'What is Energy Sparks - an introduction', embed_url: 'https://www.youtube.com/embed/yPx8LCsK_rc' },
      { title: 'An introduction to Energy Sparks for eco teams', embed_url: 'https://www.youtube.com/embed/P9yJMOP9O9w' },
      { title: 'Saundersfoot CP School and Energy Sparks', embed_url: 'https://www.youtube.com/embed/Rg0znmJtr5s' },
    ]
  end

  def set_marketing_case_studies
    @marketing_studies = {
      costs: CaseStudy.find(15),
      tool: CaseStudy.find(12),
      pupils: CaseStudy.find(13),
      emissions: CaseStudy.find(9)
    }
  end

  def set_blog_service
    @blog = BlogService.new
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
