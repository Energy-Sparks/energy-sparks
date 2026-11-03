# frozen_string_literal: true

module Schools
  class SolarEdgeInstallationsController < BaseInstallationsController
    ID_PREFIX = 'solar-edge'
    NAME = 'SolarEdge API feed'
    JOB_CLASS = Solar::SolarEdgeLoaderJob

    def show; end

    def new; end

    def edit; end

    def update
      if @installation.update(solar_edge_installation_params)
        Solar::SolarEdgeService.new(@installation).update_information
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: "#{NAME} was updated"
      else
        render :edit
      end
    end

    def check
      @api_ok = Solar::SolarEdgeService.new(@installation).check
      respond_to(&:js)
    end

    def connect
      @users = request_connection_users
    end

    def request_connection
      users = User.where(id: request_connection_params['user_ids'])
      email = request_connection_params['email']
      if users.any? || email.present?
        email_users(users, email)
        redirect_back_or_to(school_solar_feeds_configuration_index_path(@school),
                            notice: 'Connection has been requested') # rubocop:disable Rails/I18nLocaleTexts
      else
        redirect_to connect_school_solar_edge_installations_path(@school),
                    notice: 'You must choose at least one user or specify an email address' # rubocop:disable Rails/I18nLocaleTexts
      end
    end

    private

    def solar_edge_installation_params
      params.expect(solar_edge_installation: %i[site_id amr_data_feed_config_id mpan api_key active])
    end

    def request_connection_users
      users = @school.all_adult_school_users
      users += @school.organisation_group.users.group_admin if @school.organisation_group
      # sort by staff role, with missing staff roles last in the list
      users.sort_by { |u| [u.staff_role ? 0 : 1, u.staff_role] }
    end

    def email_users(users, email)
      # Email users in preferred locale, others in English
      if users.any?
        SolarEdgeMailer.with_user_locales(users:, school: @school) do |mailer|
          mailer.request_connection.deliver_now
        end
      end
      SolarEdgeMailer.with(email:, school: @school).request_connection.deliver_now if email.present?
    end

    def request_connection_params
      params.expect(request_connection: [:email, { user_ids: [] }])
    end
  end
end
