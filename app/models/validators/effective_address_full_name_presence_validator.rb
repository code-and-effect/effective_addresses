class EffectiveAddressFullNamePresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value.full_name.blank?
      record.errors[attribute] << "is invalid"
      value.errors[:full_name] << "can't be blank" 
    end
  end
end
