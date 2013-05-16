# These will be just added to the list of routes in the main application
Rails.application.routes.draw do
  get 'address/subregions/:country_code' => 'addresses#subregions'
end
