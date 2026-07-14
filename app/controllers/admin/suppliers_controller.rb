# frozen_string_literal: true

module Admin
  class SuppliersController < AdminController
    before_action :enable_bootstrap5

    load_and_authorize_resource

    def index
      @suppliers = @suppliers.by_name
    end

    def show; end

    def deliver
      @supplier = Supplier.find(params.expect(:id))
      SendSupplierReportJob.perform_later(to: current_user.email, supplier_id: @supplier.id)
      redirect_back_or_to admin_supplier_path(@supplier), notice: "Supplier report for #{@supplier.name}
                                                                  requested to be sent to #{current_user.email}"
    end

    def create
      if @supplier.save
        redirect_to admin_suppliers_path, notice: 'Supplier was successfully created.'
      else
        render :new
      end
    end

    def update
      if @supplier.update(supplier_params)
        redirect_to admin_supplier_path(@supplier), notice: 'Supplier was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @supplier.destroy
      redirect_to admin_suppliers_path, notice: 'Supplier was successfully deleted.'
    end

    private

    def supplier_params
      params.expect(supplier: %i[name owned_by_id])
    end
  end
end
