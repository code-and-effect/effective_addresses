require 'spec_helper'

describe Effective::AddressesController do
  it 'should render the subregions partial' do
    get :subregions, :country_code => 'CA'
    response.status.should be 200
    response.should render_template 'effective/addresses/_subregions'
  end

  it 'should assign appropriate Canadian subregions' do
    get :subregions, :country_code => 'CA'
    assigns(:subregions).first.name.should eq 'Alberta'
  end

  it 'should assign appropriate US subregions' do
    get :subregions, :country_code => 'US'
    assigns(:subregions).first.name.should eq 'Alaska'
  end

  it 'should assign appropriate SG subregions' do
    get :subregions, :country_code => 'SG'  # Singapore
    assigns(:subregions).first.name.should eq 'Central Singapore'
  end

  it 'Should return an error when passed bad country code' do
    get :subregions, :country_code => 'NOPE'
    response.status.should be 422 # Unprocessable Entity
  end

end
