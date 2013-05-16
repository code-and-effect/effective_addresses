# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "addresses", :force => true do |t|
    t.string   "addressable_type"
    t.integer  "addressable_id"
    t.string   "category",         :limit => 64
    t.string   "full_name"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state_code"
    t.string   "country_code"
    t.string   "postal_code"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "addresses", ["addressable_id"], :name => "index_addresses_on_addressable_id"
  add_index "addresses", ["addressable_type", "addressable_id"], :name => "index_addresses_on_addressable_type_and_addressable_id"

end
