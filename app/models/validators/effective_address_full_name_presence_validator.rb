class EffectiveAddressFullNamePresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (address = record.send(attribute)).present?
      address.errors[:full_name] << "can't be blank" unless address.full_name.present?
    end
  end
end
