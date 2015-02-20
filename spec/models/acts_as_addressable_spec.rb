require 'spec_helper'

describe User do

  describe 'Validations' do
    let(:address) { FactoryGirl.create(:address) }
    let(:address_with_full_name) { FactoryGirl.create(:address_with_full_name) }

    describe 'no requirements' do
      let(:user) { FactoryGirl.build(:user_with_address) }

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

  describe 'Many Addresses' do
    let(:user) { FactoryGirl.build(:user_with_address) }
    let(:address) { FactoryGirl.build(:address) }
    let(:address2) { FactoryGirl.build(:address) }

    it 'saves an address when parent record is saved' do
      user.billing_address = address
      user.save!

      Effective::Address.all.count.should eq 1
      user.addresses.length.should eq 1
    end

    it 'saves an additional address when parent record is saved with new address' do
      user.billing_address = address
      user.save!

      user.billing_address = address2
      user.save!

      Effective::Address.all.count.should eq 2
      user.addresses.length.should eq 2

      user.billing_address.should eq address2
      user.reload
      user.billing_address.should eq address2
    end

    it 'doesnt save an additional address when saved with a duplicate address' do
      user.billing_address = address
      user.save!

      address2.address1 = address.address1 # New object, same attributes

      user.billing_address = address2
      user.save!

      Effective::Address.all.count.should eq 1
      user.addresses.length.should eq 1

      user.billing_address.should eq address
      user.billing_address.should eq address2
    end

  end

  describe 'Singular Addresses' do
    let(:user) { FactoryGirl.build(:user_with_singular_address) }
    let(:address) { FactoryGirl.build(:address) }
    let(:address2) { FactoryGirl.build(:address) }

    it 'saves an address when parent record is saved' do
      user.billing_address = address
      user.save!

      Effective::Address.all.count.should eq 1
      user.addresses.length.should eq 1
    end

    it 'does not save an additional address when parent record is saved with new address' do
      user.billing_address = address
      user.save!

      Effective::Address.all.count.should eq 1
      user.addresses.length.should eq 1

      address_id = user.billing_address.id
      address_id.present?.should eq true

      # Now let's assign another address with different atts
      user.billing_address = address2
      user.billing_address.address1.should eq address2.address1
      user.save!

      Effective::Address.all.count.should eq 1
      user.addresses.length.should eq 1

      user.reload

      user.billing_address.id.should eq address_id

      user.billing_address.address1.should_not eq address.address1
      user.billing_address.address1.should eq address2.address1
    end

  end


end
