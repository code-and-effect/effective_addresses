# These will be just added to the list of routes in the main application
Rails.application.routes.draw do
  get 'effective/address/subregions/:country_code' => 'effective/addresses#subregions'
end
