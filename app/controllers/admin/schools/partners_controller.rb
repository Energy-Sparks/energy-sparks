module Admin
  module Schools
    class PartnersController < AdminController
      load_and_authorize_resource :school

      def show
        @partners = Partner.all.order(:name)
        @positions = @school.school_partners.inject({}) do |positions, school_partner|
          positions[school_partner.partner_id] = school_partner.position
          positions
        end
        render layout: Flipper.enabled?(:new_manage_school_pages) ? 'dashboards' : 'application'
      end

      def update
        position_attributes = params.permit(school_partners: [:position, :partner_id]).fetch(:school_partners) { {} }
        @school.update_school_partner_positions!(position_attributes)
        redirect_to admin_school_partners_path, notice: 'Partners updated'
      end
    end
  end
end
