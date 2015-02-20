require 'spec_helper'

describe User do

  describe 'Validations' do
    let(:address) { FactoryGirl.create(:address) }
    let(:address_with_full_name) { FactoryGirl.create(:address_with_full_name) }

    describe 'no requirements' do
      let(:user) { FactoryGirl.build(:user) }

      it 'is valid without an address' do
        user.valid?.should eq true
      end
    end

    describe 'required address' do
      let(:user) { FactoryGirl.build(:user_with_required_address) }

      it 'is invalid without an address' do
        user.valid?.should eq false
        user.errors[:billing_address].present?.should eq true

        # Now lets make it valid
        user.billing_address = address

        user.valid?.should eq true
        user.errors[:billing_address].present?.should eq false
      end
    end

    describe 'no required address, required full_name' do
      let(:user) { FactoryGirl.build(:user_with_required_full_name) }

      it 'is valid without an address' do
        user.valid?.should eq true
      end

      it 'is invalid when an address without full name is present' do
        user.billing_address = address
        user.valid?.should eq false
        user.errors[:billing_address].present?.should eq true

        # Now lets make it valid
        user.billing_address = address_with_full_name
        user.valid?.should eq true
        user.errors[:billing_address].present?.should eq false
      end
    end

    describe 'required address, required full_name' do
      let(:user) { FactoryGirl.build(:user_with_required_address_and_full_name) }

      it 'is invalid without an address' do
        user.valid?.should eq false
      end

      it 'is invalid when an address without full name is present' do
        user.billing_address = address
        user.valid?.should eq false
        user.errors[:billing_address].present?.should eq true

        # Now lets make it valid
        user.billing_address = address_with_full_name
        user.valid?.should eq true
        user.errors[:billing_address].present?.should eq false
      end
    end


  end
end
