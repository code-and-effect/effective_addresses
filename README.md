# Effective Addresses

Provides helper methods for dealing with a has_many :addresses relationship as a single method.

Creates methods such as @user.billing_address and @user.billing_address=

Includes full validations for addresses with multiple categories.

Includes a Formtastic & SimpleForm helper method to create/update the address of a parent object.

Uses the Carmen gem so when a Country is selected, an AJAX request populates the State/Province fields as appropriate.

Rails 3.2.x and Rails 4 Support

## Getting Started

Add to your Gemfile:

```ruby
gem 'effective_addresses', :git => 'https://github.com/code-and-effect/effective_addresses'
```

Run the bundle command to install it:

```console
bundle install
```

Then run the generator:

```ruby
rails generate effective_addresses:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

If you want to tweak the table name (to use something other than the default 'addresses'), manually adjust both the configuration file and the migration now.

Then migrate the database:

```ruby
rake db:migrate
```

If you'd like to use the form helper method, require the javascript in your application.js

```ruby
//= require effective_addresses
```


## Usage

### Model

To create a address, just add the mixin to your existing model and specify the name of the address

To use without any validations, just add the mixin to your existing model:

```ruby
class User
  acts_as_addressable :billing
end
```

Calling @user.billing_address will return a single Effective::Address.  Calling @user.billing_addresses will return an array of Effective:Addresses

This adds the following getters, along with the setters:

```ruby
@user.billing_address
@user.billing_address=
@user.billing_addresses
```

Using the effective_addresses.config.full_name value from the initializer, you can also define validations, simply, as follows:

```ruby
class User
  acts_as_addressable :billing => true, :shipping => false
end
```

This means when a User is created, it will not be valid unless a billing_address exist and is valid.

Or you can define validations, with a bit more detail, as follows:

```ruby
class User
  acts_as_addressable :billing => {:presence => true, :use_full_name => false}
end
```


### Multiple Addresses

Everytime an address is changed, an additional address record is created.  The latest address will always be returned by:

```ruby
@user.billing_address
```

You can find all past addresses (including the current one) by:

```ruby
@user.billing_addresses
```

### Strong Parameters

Make your controller aware of the acts_as_addressable passed parameters:

```ruby
def permitted_params
  params.require(:base_object).permit(
    :billing_address => [:full_name, :address1, :address2, :city, :country_code, :state_code, :postal_code],
    :shipping_address => [:full_name, :address1, :address2, :city, :country_code, :state_code, :postal_code]
  )
end
```

### Helpers

Use the helper in a formtastic or simpleform form to quickly create the address fields.  This example is in HAML:

```ruby
= semantic_form_for @user do |f|
  %h3 Billing Address
  = effective_address_fields(f, :billing_address)

  = f.action :submit

= simple_form_for @user do |f|
  %h3 Billing Address
  = effective_address_fields(f, :billing_address)

  = f.submit 'Save'
```

Currently only supports Formtastic and SimpleForm.

Assuming the javascript has been properly required (as above), when you select a country from the dropdown
an AJAX GET request will be made to '/effective/address/subregions/:country_code' and populate the state dropdown with the appropriate states or provinces


## License

MIT License.  Copyright Code and Effect Inc. http://www.codeandeffect.com

You are not granted rights or licenses to the trademarks of Code and Effect


## Testing

The test suite for this gem is unfortunately not yet complete.

Run tests by:

```ruby
rake spec
```
















