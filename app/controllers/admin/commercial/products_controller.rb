module Admin::Commercial
  class ProductsController < AdminController
    load_and_authorize_resource :product, class: 'Commercial::Product'

    def index
      @products = Commercial::Product.with_default_first
    end

    def create
      @product = Commercial::Product.build(product_params.merge(created_by: current_user))
      if @product.save
        redirect_to admin_commercial_products_path, notice: 'Product has been created'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @product.update(product_params.merge(updated_by: current_user))
        redirect_to admin_commercial_products_path, notice: 'Product has been updated'
      else
        render :edit
      end
    end

    def destroy
      if @product.destroy
        redirect_to(admin_commercial_products_path, notice: 'Product has been deleted')
      else
        redirect_to(admin_commercial_products_path, alert: @product.errors.full_messages.to_sentence)
      end
    end

    private

    def product_params
      params.require(:product).permit(:name, :comments, :default_product, :small_school_price, :large_school_price, :size_threshold, :mat_price,
      :private_account_fee, :metering_fee)
    end
  end
end
