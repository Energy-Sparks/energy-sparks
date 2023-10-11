module Admin
  module Schools
    class PartnersController < AdminController
      load_and_authorize_resource :school

      def show
        @partners = Partner.all.order(:name)
        @positions = @school.school_partners.each_with_object({}) do |school_partner, positions|
          positions[school_partner.partner_id] = school_partner.position
        end
      end

      def update
        position_attributes = params.permit(school_partners: %i[position partner_id]).fetch(:school_partners) { {} }
        @school.update_school_partner_positions!(position_attributes)
        redirect_to admin_school_partners_path, notice: 'Partners updated'
      end
    end
  end
end
