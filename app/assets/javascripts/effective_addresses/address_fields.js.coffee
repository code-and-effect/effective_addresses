loadSubregions = ($countrySelect, clearPostalCode = false) ->
  $.each $countrySelect, (index, countrySelector) ->
    $particularCountrySelect = $(countrySelector)
    countryCode = $particularCountrySelect.val() || ''
    uuid = $particularCountrySelect.data('effective-address-country')

    $nestedFields = $particularCountrySelect.closest('.nested-fields')
    $form = $particularCountrySelect.closest('form')

    $container = if $nestedFields.length == 0 then $form else $nestedFields

    # clear postal_code values on country change if it is turned on
    $container.find("input[data-effective-address-postal-code='#{uuid}']").val('') if clearPostalCode

    # load state options
    url = "/addresses/subregions/#{countryCode}"
    $stateSelect = $container.find("select[data-effective-address-state='#{uuid}']:first")

    return unless $stateSelect.length
    prompts = $stateSelect.data('effective-address-prompts') || {}
    fallback = $stateSelect.data('input-js-options')?.placeholder || $stateSelect.find("option[value='']").text()

    if countryCode.length == 0
      $stateSelect.prop('disabled', true).addClass('disabled').parent('.form-group').addClass('disabled').find('label').addClass('disabled')
      reinitialize($stateSelect, prompts.country_first || fallback)
    else
      $stateSelect.removeAttr('disabled').parent('.form-group').removeClass('disabled').find('.disabled').removeClass('disabled')
      reinitialize($stateSelect, prompts.loading || fallback)

      $stateSelect.load url, ->
        stateSelectAvailable = ($(@).find('option:last').val() || '').length > 0
        if stateSelectAvailable
          $(@).prop('required', true)
          $(@).removeAttr('disabled')
          reinitialize($stateSelect, prompts.choose || fallback, true)
        else
          $(@).removeAttr('required')
          $(@).prop('disabled', true)
          reinitialize($stateSelect, prompts.none || fallback, true)

$(document).on 'change', 'select[data-effective-address-country]', -> loadSubregions($(@), true)

reinitialize = ($stateSelect, placeholder, keepOptions = false) ->
  if $stateSelect.hasClass('effective_select') == false
    $stateSelect.empty() unless keepOptions
    $prompt = $stateSelect.find("option[value='']").first()
    if $prompt.length
      $prompt.text(placeholder)
    else
      $stateSelect.prepend($('<option>').val('').text(placeholder))
    $stateSelect.val('')
    return

  $stateSelect.html('') unless keepOptions
  $stateSelect.val('')

  opts = $stateSelect.data('input-js-options') || {}
  opts['placeholder'] = placeholder
  $stateSelect.data('input-js-options', opts)

  $stateSelect.select2().trigger('select2:reinitialize')
