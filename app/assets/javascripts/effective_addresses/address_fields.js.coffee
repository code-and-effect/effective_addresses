loadSubregions = ($countrySelect, clearPostalCode = false) ->
  $.each $countrySelect, (index, countrySelector) ->
    $particularCountrySelect = $(countrySelector)
    countryCode = $particularCountrySelect.val()
    uuid = $particularCountrySelect.data('effective-address-country')

    $nestedFields = $particularCountrySelect.closest('.nested-fields')
    $form = $particularCountrySelect.closest('form')

    $container = if $nestedFields.length == 0 then $form else $nestedFields

    # clear postal_code values on country change if it is turned on
    $container.find("input[data-effective-address-postal-code='#{uuid}']").val('') if clearPostalCode

    # load state options
    url = "/addresses/subregions/#{countryCode}"
    $stateSelect = $container.find("select[data-effective-address-state='#{uuid}']:first")

    if countryCode.length == 0
      $stateSelect.prop('disabled', true).addClass('disabled').parent('.form-group').addClass('disabled').find('label').addClass('disabled')
      reinitialize($stateSelect, 'Please choose country first')
    else
      $stateSelect.removeAttr('disabled').parent('.form-group').removeClass('disabled').find('.disabled').removeClass('disabled')
      reinitialize($stateSelect, 'Loading...')

      $stateSelect.load url, ->
        stateSelectAvailable = $(@).find('option:last').val().length > 0
        if stateSelectAvailable
          $(@).prop('required', true)
          $(@).removeAttr('disabled')
          reinitialize($stateSelect, 'Please choose', true)
        else
          $(@).removeAttr('required')
          $(@).prop('disabled', true)
          reinitialize($stateSelect, 'None exist', true)

$(document).on 'change', 'select[data-effective-address-country]', -> loadSubregions($(@), true)

reinitialize = ($stateSelect, placeholder, keepOptions = false) ->
  if $stateSelect.hasClass('effective_select') == false
    $stateSelect.html("<option value=''>#{placeholder}</option>") unless keepOptions
    return

  $stateSelect.html('') unless keepOptions

  opts = $stateSelect.data('input-js-options')
  opts['placeholder'] = placeholder
  $stateSelect.data('input-js-options', opts)

  $stateSelect.select2().trigger('select2:reinitialize')
