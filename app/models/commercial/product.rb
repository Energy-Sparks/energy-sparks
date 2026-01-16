# == Schema Information
#
# Table name: commercial_products
#
#  comments            :text
#  created_at          :datetime         not null
#  created_by_id       :bigint(8)
#  default_product     :boolean          default(FALSE), not null
#  id                  :bigint(8)        not null, primary key
#  large_school_price  :decimal(10, 2)
#  mat_price           :decimal(10, 2)
#  metering_fee        :decimal(10, 2)
#  name                :string           not null
#  private_account_fee :decimal(10, 2)
#  size_threshold      :integer
#  small_school_price  :decimal(10, 2)
#  updated_at          :datetime         not null
#  updated_by_id       :bigint(8)
#
# Indexes
#
#  index_commercial_products_on_created_by_id    (created_by_id)
#  index_commercial_products_on_default_product  (default_product) UNIQUE WHERE (default_product = true)
#  index_commercial_products_on_name             (name) UNIQUE
#  index_commercial_products_on_updated_by_id    (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (updated_by_id => users.id)
#
module Commercial
  class Product < ApplicationRecord
    include Trackable

    self.table_name = 'commercial_products'

    validates_presence_of :name
    validates :default_product, uniqueness: { message: 'already exists' }, if: :default_product?

    scope :with_default_first, -> {
      order(default_product: :desc).order(:name)
    }

    has_many :contracts, class_name: 'Commercial::Contract'
  end
end
