$(document).on 'change', "input[name$='[shipping_address][shipping_address_same_as_billing]']", (event) ->
  $obj = $(event.currentTarget)

  shipping_fields = $obj.closest('form').find("
    div[class*='_shipping_address_full_name'],
    div[class*='_shipping_address_address1'],
    div[class*='_shipping_address_address2'],
    div[class*='_shipping_address_address3'],
    div[class*='_shipping_address_city'],
    div[class*='_shipping_address_country_code'],
    div[class*='_shipping_address_state_code'],
    div[class*='_shipping_address_postal_code'],
    div[class*='shipping_address_form_group']
  ")

  if $obj.is(':checked')
    shipping_fields.hide().find('input,select').prop('disabled', true).prop('required', true)
  else
    shipping_fields.show().find('input,select').removeAttr('disabled').removeAttr('required')


