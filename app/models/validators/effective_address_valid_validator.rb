class EffectiveAddressValidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (address = record.send(attribute)).present?
      record.errors[attribute] << 'must be valid' unless address.valid?
    end
  end
end
