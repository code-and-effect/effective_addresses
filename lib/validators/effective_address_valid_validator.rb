class EffectiveAddressValidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !value.empty? && !value.valid?
      record.errors.add(attribute, :invalid)
    end
  end
end
