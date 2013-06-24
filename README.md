# Effective Addresses

Provides helper methods for dealing with a has_many :addresses relationship as a single method.
Such as @user.billing_address and @user.billing_address=

Includes full validations for addresses with multiple categories.

Includes a formtastic helper method to create/update the address of a parent object.
Uses the Carmen gem so when a Country is selected, an AJAX request populates the State/Province fields as appropriate.

Rails >= 3.2.x, Ruby >= 1.9.x.  Has not been tested/developed for Rails4.

## Getting Started

Add to your Gemfile:

```ruby
gem 'effective_addresses'
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

To use without any validations, just add the mixin to your existing model:

```ruby
class User
  acts_as_addressable
end
```

This adds the following getters, along with the setters:

```ruby
@user.address
@user.billing_address
@user.shipping_address
@user.primary_address
@user.secondary_address
```

You can also define validations as follows:

```ruby
class User
  acts_as_addressable :require_billing => true, :require_shipping => true
end
```

This means when a User is created, it will not be valid unless a billing_address and shipping_address exist and are valid.

### Multiple Addresses

Everytime an address is changed, an additional address record is created.  The latest address will always be returned by:

```ruby
@user.billing_address
```

You can find all past addresses (including the current one) by:

```ruby
@user.billing_addresses
```

### Form Helper

Use the helper in a formtastic form to quickly create the address fields 'f.inputs'.  This example is in HAML:

```ruby
= semantic_form_for @user do |f|
  = f.inputs :name => "Your Information" do
    = f.input :email
    = f.input :name

  = effective_address_fields(f, :category => 'billing') # 'shipping', 'primary', 'secondary'

  = f.action :submit
```

Currently only supports Formtastic.

Assuming the javascript has been properly required (as above), when you select a country from the dropdown
an AJAX GET request will be made to '/effective/address/subregions/:country_code' and populate the state dropdown with the appropriate states or provinces


## License

MIT License.  Copyright Code and Effect Inc. http://www.codeandeffect.com

You are not granted rights or licenses to the trademarks of Code and Effect

## Notes

This is a work in progress gem.  It needs smarter validations, dynamic methods and google maps integration

### Testing

The test suite for this gem is unfortunately not yet complete.

Run tests by:

```ruby
rake spec
```
















