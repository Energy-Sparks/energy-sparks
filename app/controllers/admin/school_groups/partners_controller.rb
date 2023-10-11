module Admin
  module SchoolGroups
    class PartnersController < AdminController
      load_and_authorize_resource :school_group

      def show
        @partners = Partner.all.order(:name)
        @positions = @school_group.school_group_partners.each_with_object({}) do |school_group_partner, positions|
          positions[school_group_partner.partner_id] = school_group_partner.position
        end
      end

      def update
        position_attributes = params.permit(school_group_partners: %i[position partner_id]).fetch(:school_group_partners) { {} }
        @school_group.update_school_partner_positions!(position_attributes)
        redirect_to admin_school_group_path(@school_group), notice: 'Partners updated'
      end
    end
  end
end
