require 'spec_helper'

describe Effective::Address do
  let(:address) { FactoryGirl.create(:address) }

  it "should be valid" do
    address.valid?.should == true
  end

  it "should be able to clone" do
    address2 = address.dup
    address2.save

    address.full_name.should == address2.full_name
    address.address1.should == address2.address1
    address.address2.should == address2.address2
    address.city.should == address2.city
    address.state.should == address2.state
    address.country.should == address2.country
    address.postal_code.should == address2.postal_code
    address.category.should == address2.category

    address.id.should_not == address2.id
    address.created_at.should_not == address2.created_at
    address.updated_at.should_not == address2.updated_at
  end

  it "should compare details and == to another address" do
    address2 = address.dup
    address2.save

    address.should == address2

  end

end
