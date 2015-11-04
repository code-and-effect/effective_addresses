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
      $stateSelect.prop('disabled', true).addClass('disabled').parent('.form-group').addClass('disabled')
      $stateSelect.html('<option value="">Please choose a country first</option>')
    else
      $stateSelect.removeAttr('disabled').removeClass('disabled').parent('.form-group').removeClass('disabled')
      $stateSelect.find('option').first().text('loading...')
      $stateSelect.load url, ->
        stateSelectAvailable = $(@).find('option:last').val().length > 0
        if stateSelectAvailable
          $(@).prop('required', true)
          $(@).removeAttr('disabled')
        else
          $(@).removeAttr('required')
          $(@).prop('disabled', true)

$(document).on 'change', 'select[data-effective-address-country]', -> loadSubregions($(@), true)

$ -> loadSubregions($('select[data-effective-address-country]'))
$(document).on 'page:change', -> loadSubregions($('select[data-effective-address-country]'))
