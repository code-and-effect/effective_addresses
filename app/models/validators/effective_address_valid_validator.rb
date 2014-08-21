class EffectiveAddressValidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value.valid? == false
      record.errors[attribute] << 'is invalid'
    end
  end
end
