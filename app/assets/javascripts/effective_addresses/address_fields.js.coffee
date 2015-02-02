$(document).on 'change', "select[data-effective-address-country]", (event) ->
  country_code = $(this).val()
  uuid = $(this).data('effective-address-country')

  url = "/addresses/subregions/#{country_code}"
  state_select = $(this).closest('form').find("select[data-effective-address-state='#{uuid}']").first()

  if country_code.length == 0
    state_select.prop('disabled', true).addClass('disabled').parent('.form-group').addClass('disabled')
    state_select.html('<option value="">Please choose a country first</option>')
  else
    state_select.prop('disabled', false).removeClass('disabled').parent('.form-group').removeClass('disabled')
    state_select.find('option').first().text('loading...')
    state_select.load(url)
