module Effective
  class AddressesController < ApplicationController
    skip_authorization_check if defined? CanCan
    respond_to :json

    def subregions
      country_code = params[:country_code]

      if country_code.present?
        render :partial => 'addresses/subregions', :locals => {:country_code => country_code}
      else
        render :text => '', :status => :unprocessable_entity
      end
    end
  end
end
