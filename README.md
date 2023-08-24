# Effective Addresses

Extend any ActiveRecord object to have one or more named addresses. Includes a geographic region-aware custom form input backed by Carmen.

Creates methods such as `user.billing_address` and `user.billing_address=` for dealing with a has_many :addresses relationship as a single method.

Adds region-aware validations for provinces/states and postal codes.

Includes a Formtastic and SimpleForm one-liner method to drop in address fields to any form.

Uses the Carmen gem internally so when a Country is selected, an AJAX request populates the province/state fields as appropriate.

## Getting Started

Add to your Gemfile:

```ruby
gem 'effective_addresses'
```

Run the bundle command to install it:

```console
bundle install
```

If you're using effective_addresses from within a rails engine (optional):

```ruby
require 'effective_addresses'
```

Then run the generator:

```ruby
rails generate effective_addresses:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

If you want to tweak the table name (to use something other than the default `addresses`), manually adjust both the configuration file and the migration now.

Then migrate the database:

```ruby
rake db:migrate
```

And require the javascript in your application.js:

```ruby
//= require effective_addresses
```


## Usage

### Model

Add the mixin to your existing model and specify the name or names of the addresses it should respond to:

```ruby
class User
  acts_as_addressable :billing
end
```

This adds the following getters and setters:

```ruby
@user.billing_address
@user.billing_address=
@user.billing_addresses
```

Calling `user.billing_address` will return a single `Effective::Address` object.  Calling `user.billing_addresses` will return an array of `Effective:Address` objects.

You can also specify a `:presence` validation as follows:

```ruby
class User
  acts_as_addressable :billing => true, :shipping => false
end
```

or

```ruby
class User
  acts_as_addressable :billing => {:presence => true}
end
```

or

```ruby
class User
  acts_as_addressable :billing

  validates_presence_of :billing_address
end
```

This means when a User is created, it will not be valid unless a billing_address exist and is valid.


### Full Name

Sometimes you want to collect a `full_name` field with your addresses, such as in the case of a mailing address; other times, it's an unnecessary field.

When you specify the config option `config.use_full_name = true` all, any calls to `effective_address_fields` form helper will display the full_name input, and the model will `validate_presence_of :full_name`.


### Address Validations

Address1, City, Country and Postal/Zip Code are all required fields.

If the selected Country has provinces/states (not all countries do), then the province/state field will be required.

If the country is Canada or United States, then the postal/zip code formatting will be enforced.

This validation on the postal code/zip format can be disabled via the config/initializers `validate_postal_code_format` setting

Canadian postal codes will be automatically upcased and formatted to a consistent format: `T5Z 3A4` (capitalized with a single space).


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

Make your controller aware of the `acts_as_addressable` passed parameters:

```ruby
def permitted_params
  params.require(:base_object).permit(
    :billing_address => EffectiveAddresses.permitted_params,
    :shipping_address => EffectiveAddresses.permitted_params
  )
end
```

The actual permitted parameters are:

```ruby
[:full_name, :address1, :address2, :city, :country_code, :state_code, :postal_code]
```

### Form Helpers

Use the helper in a Formtastic or SimpleForm form to quickly create the address fields. Currently only supports Formtastic and SimpleForm.

When you select a country from the select input an AJAX GET request will be made to `effective_addresses.address_subregions_path` (`/addresses/subregions/:country_code`)
which populates the province/state dropdown with the selected country's states or provinces.


#### Formtastic

```ruby
= semantic_form_for @user do |f|
  %h3 Billing Address
  = effective_address_fields(f, :billing_address)

  = f.action :submit
```

#### SimpleForm

```ruby
= simple_form_for @user do |f|
  %h3 Billing Address
  = effective_address_fields(f, :billing_address)

  = f.submit 'Save'
```

#### Field Ordering
You may choose to order fields different than the default, such as putting the country first.  You can do so with the `:field_order` option, for example:
```ruby
= simple_form_for @user do |f|
  %h3 Billing Address
  = effective_address_fields(f, :billing_address, :field_order => [:country_code, :full_name, :address1, :address2, :city, :state_code, :postal_code])

  = f.submit 'Save'
```

## Geocoder option

Effective addresses has an optional integration with [Geocoder](https://github.com/alexreisner/geocoder).  At it's simplest, this provides preselection and prefill of `country`, `state`, `city`, and `postal_code` based on the user's IP address. See [Geocoder](https://github.com/alexreisner/geocoder) for
a complete list of possibilities.

### Installation and Setup

```ruby
gem 'geocoder'
```

Add `config/initializer/geocoder.rb`, below is a sample:

```ruby
Geocoder.configure(
    # Remote IP address geocoding service (see below for supported options):
    #    https://github.com/alexreisner/geocoder#ip-address-services
    ip_lookup: :telize,

    # Local IP address file database:
    # 1. gem 'maxminddb'
    # 2. download database: http://dev.maxmind.com/geoip/geoip2/geolite2/
    # 3. save file in db/geocoder
    # ip_lookup: :geoip2,
    # geoip2: { file: File.expand_path('../../db/geocoder/GeoLite2-City.mmdb', File.dirname(__FILE__)) },

    cache: Rails.cache,
    cache_prefix: 'geocoder:'
)

# Provide a hardcoded ip of 1.2.3.4 when in developmnt/test and the ip address resolves as localhost
if %w(development test).include? Rails.env
  module Geocoder
    module Request
      def geocoder_spoofable_ip_with_localhost_override
        ip_candidate = geocoder_spoofable_ip_without_localhost_override
        if ip_candidate == '127.0.0.1'
          '1.2.3.4'
        else
          ip_candidate
        end
      end
      alias_method_chain :geocoder_spoofable_ip, :localhost_override
    end
  end
end
```


## License

MIT License.  Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

## Testing

The test suite for this gem is unfortunately not yet complete.

Run tests by:

```ruby
rake spec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
