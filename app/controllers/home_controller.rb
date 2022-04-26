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

  def for_teachers
    @testimonial = [{
      quote: 'The website is a great resource for adults and children with activities and data which allow children to apply their mathematical and scientific skills and knowledge. I would highly recommend to any other school.',
      by: 'Jennie Nixon',
      title: 'Head of School',
      location: 'Whiteways Primary School, Sheffield'
    }, {
      quote: 'The Energy Sparks website is very easy to use, and the children have found it interesting to measure how energy is used differently in different parts of the school&hellip; The children are motivated by the competitive element as well as the desire to save money and energy&hellip;',
      by: 'Warrick Barton',
      title: 'Headteacher',
      location: 'Pensford Primary School, Bath'
    }].sample
  end

  def for_schools
    @videos = [
      { title: 'An overview of Energy Sparks for new schools', embed_url: 'https://www.youtube.com/embed/ltIDE9C4bO8' },
      { title: 'An introduction to Energy Sparks for eco teams', embed_url: 'https://www.youtube.com/embed/P9yJMOP9O9w' },
      { title: 'Saundersfoot CP School and Energy Sparks', embed_url: 'https://www.youtube.com/embed/Rg0znmJtr5s' },
    ]
  end

  def for_pupils
  end

  def for_management
  end

  def contact
  end

  def enrol
  end

  def privacy_and_cookie_policy
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
    @school_groups = ComparisonService.new(current_user).list_school_groups
  end

  def team
    @staff = TeamMember.staff.order(:position)
    @consultants = TeamMember.consultant.order(:position)
    @trustees = TeamMember.trustee.order(:position)
    @partners = Partner.order(:position)
  end

  private

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
