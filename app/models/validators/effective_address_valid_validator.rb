class EffectiveAddressValidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !value.empty? && !value.valid?
      record.errors[attribute] << 'is invalid'
    end
  end
end
