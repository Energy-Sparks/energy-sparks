class LandingPagesController < ApplicationController
  TRUST = 'multi_academy_trust'.freeze
  LA = 'local_authority'.freeze
  # Needs to be aligned with values in set_org_types
  GROUP_TYPES = [TRUST, LA].freeze

  skip_before_action :authenticate_user!
  before_action :set_org_types, only: [:watch_demo, :more_information]
  layout 'home', only: [:watch_demo, :more_information]

  def index
    redirect_to product_path
  end

  def mat_pack
    redirect_to url_for(controller: :resource_files, action: :download, serve: :inline, id: 30)
  end

  def school_pack
    redirect_to url_for(controller: :resource_files, action: :download, serve: :inline, id: 29)
  end

  def demo_video
    redirect_to 'https://www.youtube.com/watch?v=x2EeYWwdEpE'
  end

  def short_demo_video
    redirect_to 'https://www.youtube.com/watch?v=lEiiEyAcVu4'
  end

  def long_demo_video
    redirect_to 'https://www.youtube.com/watch?v=F5bL1_HsI0U'
  end

  def example_adult_dashboard
    redirect_to school_path(find_example_school)
  end

  def example_pupil_dashboard
    redirect_to pupils_school_path(find_example_school)
  end

  def example_mat_dashboard
    redirect_to school_group_path(find_example_group)
  end

  def example_la_dashboard
    redirect_to school_group_path(find_example_local_authority)
  end

  # User would like to watch a demo - display form
  def watch_demo
  end

  # User would like more information - display form
  def more_information
  end

  # Process forms and submit job
  def thank_you
    CampaignContactHandlerJob.perform_later(request_type, contact_for_capsule)
    case request_type
    when :group_demo
      @calendly_data_url = calendly_data_url
      render :group_demo, layout: 'home'
    when :school_demo # will be able to remove this (and just use else clause) once new info flow is in place (if we use same layout)
      render :school_demo, layout: 'home'
    else # currently group_info or school_info
      render request_type # , layout: 'home' # for new info flow
    end
  end

private

  # request_type can be one of:
  # :grouop_demo, :school_demo, :group_info or :school_info
  def request_type
    raise unless source.in?(%w[info demo]) # check this since it comes from form params
    "#{contact_in_group? ? 'group' : 'school'}_#{source}".to_sym
  end

  def contact_for_capsule
    contact_params.merge(consent: ActiveModel::Type::Boolean.new.cast(contact_params['consent'])).to_h.symbolize_keys
  end

  def contact_in_group?
    contact_params[:org_type].any? {|t| GROUP_TYPES.include? t }
  end

  def calendly_data_url
    calendly_params = {
      name: "#{contact_params['first_name']} #{contact_params['last_name']}",
      email: contact_params[:email],
      a1: contact_params[:tel].gsub(/^0/, '+44'),
      a2: contact_params[:organisation]
    }.to_param.gsub('+', '%20')
    "https://calendly.com/energy-sparks/mat-demo?#{calendly_params}"
  end

  def set_org_types
    @org_types = %i[multi_academy_trust primary secondary special independent local_authority].index_by do |type|
      I18n.t("campaigns.form.org_types.#{type}")
    end
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name,
      :job_title, :organisation, { org_type: [] }, :email, :tel, :consent)
  end

  def source
    params.permit(:source)[:source]
  end

  def find_example_school
    School.find_by_slug('northampton-academy') || School.data_enabled.visible.sample
  end

  def find_example_group
    SchoolGroup.find_by_slug('united-learning') || SchoolGroup.is_public.multi_academy_trust.sample(1)
  end

  def find_example_local_authority
    SchoolGroup.find_by_slug('pembrokeshire-sir-penfro') || SchoolGroup.is_public.local_authority.sample(1)
  end
end
