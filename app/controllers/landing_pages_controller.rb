class LandingPagesController < ApplicationController
  # Needs to be aligned with values in set_org_types
  GROUP_TYPES = %w[multi_academy_trust local_authority].freeze

  skip_before_action :authenticate_user!
  before_action :set_marketing_case_studies
  before_action :set_org_types, only: [:book_demo, :more_information]

  def index
    redirect_to find_out_more_campaigns_path
  end

  def mat_pack
    redirect_to url_for(controller: :resource_files, action: :download, serve: :inline, id: 30)
  end

  def school_pack
    redirect_to url_for(controller: :resource_files, action: :download, serve: :inline, id: 29)
  end

  def example_adult_dashboard
    redirect_to school_path(find_example_school)
  end

  def example_pupil_dashboard
    redirect_to pupils_school_path(find_example_school)
  end

  def example_group_dashboard
    redirect_to school_group_path(find_example_group)
  end

  # Main entry point
  def find_out_more
    render :find_out_more, layout: 'home'
  end

  # Display contact form, to book a demo
  def book_demo
  end

  # Display contact form, to request more information
  def more_information
  end

  # Process forms and submit job
  def submit_contact
    request_type = contact_params['request_type'].to_sym
    contact = contact_for_capsule
    CampaignContactHandlerJob.perform_later(request_type, contact)
    redirect_to thank_you_campaigns_path(redirect_params(request_type, contact))
  end

  # Final step either shows confirmation or embedded booking form
  def thank_you
    case params[:request_type].to_sym
    when :book_demo
      @calendly_data_url = calendly_data_url
      render :book_demo_final
    else
      render :more_info_final
    end
  end

  private

  def contact_for_capsule
    contact = contact_params.except('request_type')
    contact['consent'] = ActiveModel::Type::Boolean.new.cast(contact['consent'])
    contact.to_h
  end

  def trust_or_local_authority?
    contact_params[:org_type].any? {|t| GROUP_TYPES.include? t }
  end

  def calendly_event_type
    trust_or_local_authority? ? 'mat-demo' : 'demo-for-individual-schools'
  end

  def calendly_data_url
    event_type = params[:event_type] || 'demo-for-individual-schools'
    calendly_params = {
      name: params[:name],
      email: params[:email],
      a1: params[:tel],
      a2: params[:organisation]
    }.to_param
    "https://calendly.com/energy-sparks/#{event_type}?#{calendly_params}"
  end

  def redirect_params(request_type, contact)
    params = {
      request_type: request_type
    }
    case request_type
    when :book_demo
      params.merge!({
        event_type: calendly_event_type,
        name: "#{contact['first_name']} #{contact['last_name']}",
        email: contact['email'],
        tel: contact['tel'].gsub(/^0/, '+44'), # Ensures number is shown correctly in calendly widget
        organisation: contact['organisation']
      })
    else
      params
    end
  end

  def set_marketing_case_studies
    @marketing_studies = {
      costs: CaseStudy.find(15),
      tool: CaseStudy.find(12),
      pupils: CaseStudy.find(13),
      emissions: CaseStudy.find(9)
    }
  end

  def set_org_types
    @org_types = {
      I18n.t('campaigns.form.org_types.multi_academy_trust') => :multi_academy_trust,
      I18n.t('campaigns.form.org_types.primary') => :primary,
      I18n.t('campaigns.form.org_types.secondary') => :secondary,
      I18n.t('campaigns.form.org_types.special') => :special,
      I18n.t('campaigns.form.org_types.independent') => :independent,
      I18n.t('campaigns.form.org_types.local_authority') => :local_authority
    }.sort
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :job_title, :organisation, { org_type: [] }, :email, :tel, :consent, :request_type)
  end

  def find_example_school
    School.find_by_id('northampton-academy') || School.data_enabled.visible.sample(1)
  end

  def find_example_group
    SchoolGroup.find_by_id('united-learning') || SchoolGroup.is_public.with_schools.sample(1)
  end
end
