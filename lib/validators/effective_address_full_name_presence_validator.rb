class EffectiveAddressFullNamePresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !value.empty? && value.full_name.blank?
      record.errors.add(attribute, :invalid)
      value.errors.add(:full_name, :blank)
    end
  end
end
