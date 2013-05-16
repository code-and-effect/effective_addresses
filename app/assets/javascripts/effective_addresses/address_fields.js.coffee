$(document).on 'change', "select[data-behavior='address-country']", (event) ->
  country_code = $(this).val()

  url = "/address/subregions/#{country_code}"
  state_select = $(this).parent().parent().find("li > select[data-behavior='address-state']").first()

  if country_code.length == 0
    state_select.attr('disabled', 'disabled')
    state_select.html('<option value="">please select a country</option>')
  else
    state_select.removeAttr('disabled')
    state_select.find('option').first().text('loading...')
    state_select.load(url)
