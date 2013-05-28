require 'spec_helper'

describe Effective::AddressesController do
  it 'Should return the proper subregion html' do
    get :subregions, :country_code => 'CA'
    response.status.should be 200
  end


end
