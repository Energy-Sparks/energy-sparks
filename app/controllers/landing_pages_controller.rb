class LandingPagesController < ApplicationController
  TRUST = 'multi_academy_trust'.freeze
  LA = 'local_authority'.freeze
  # Needs to be aligned with values in set_org_types
  GROUP_TYPES = [TRUST, LA].freeze

  skip_before_action :authenticate_user!
  before_action :set_org_types, only: [:demo, :more_information]
  # layout 'home', only: [:demo, :more_information] # TODO

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

  # User would like a demo - display form
  def demo
  end

  # User would like more information - display form
  def more_information
  end

  def book_demo_params
    params = contact_params.slice('utm_source', 'utm_medium', 'utm_campaign', 'email', 'organisation')
    params.merge!({
      name: "#{contact_params['first_name']} #{contact_params['last_name']}",
      tel: contact_params['tel'].gsub(/^0/, '+44'), # Ensures number is shown correctly in calendly widget
    })
  end

  # Process forms and submit job
  def thank_you
    CampaignContactHandlerJob.perform_later(request_type, contact_for_capsule)
    case request_type
    when :book_demo
      redirect_to book_demo_campaigns_path(book_demo_params)
    when :video_demo
      render :video_demo, layout: 'home'
    else
      render :more_info_final
    end
  end

  def book_demo
    @calendly_data_url = calendly_data_url
  end

  # override the application helper version
  def utm_params_for_redirect
    contact_params.slice(:utm_source, :utm_medium, :utm_campaign).to_h
  end
  helper_method :utm_params_for_redirect

private

  def request_type
    source = contact_params['source']&.to_sym
    return :more_information unless source == :demo
    includes_group? ? :book_demo : :video_demo
  end

  def contact_for_capsule
    contact = contact_params.except('source', 'utm_source', 'utm_medium', 'utm_campaign')
    contact['consent'] = ActiveModel::Type::Boolean.new.cast(contact['consent'])
    contact.to_h
  end

  def includes_group?
    contact_params[:org_type].any? {|t| GROUP_TYPES.include? t }
  end

  def calendly_data_url
    calendly_params = {
      name: params[:name],
      email: params[:email],
      a1: params[:tel],
      a2: params[:organisation]
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
      :job_title, :organisation, { org_type: [] }, :email, :tel, :consent, :source,
      :utm_source, :utm_medium, :utm_campaign)
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
