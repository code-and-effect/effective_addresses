class EffectiveAddressPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    num_present = (record.addresses || []).select { |address| address.category == attribute.to_s.gsub('_address', '') && address.marked_for_destruction? == false }.size
    record.errors[attribute] << "can't be blank" if num_present == 0
  end
end
