class BillingAddressValidator < ActiveModel::Validator
  def validate(record)
    address = record.try(:billing_address)

    record.errors[:billing_address] << "valid billing address is required" unless (address.present? and address.valid?)
  end
end
