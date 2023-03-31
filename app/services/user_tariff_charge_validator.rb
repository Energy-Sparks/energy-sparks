class UserTariffChargeValidator
  attr_reader :user_tariff_charges, :message

  def initialize(user_tariff_charges)
    @user_tariff_charges = user_tariff_charges
    @message = nil
  end

  def valid?
    @user_tariff_charges.map(&:valid?)

    charge_types = @user_tariff_charges.map(&:charge_type)
    if %w(agreed_availability_charge excess_availability_charge).intersection(charge_types).present?
      @message = "Available capacity must be set if Agreed Availability of Excess Availability are set" unless charge_types.include?('asc_limit_kw')
    end

    @user_tariff_charges.all?(&:valid?) && @message.blank?
  end
end
