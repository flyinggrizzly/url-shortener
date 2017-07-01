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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170701123141) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "short_url_hits", force: :cascade do |t|
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "short_url_id"
    t.index ["short_url_id"], name: "index_short_url_hits_on_short_url_id"
  end

  create_table "short_urls", force: :cascade do |t|
    t.string "slug"
    t.text "redirect"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "admin", default: false
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "short_url_hits", "short_urls"
end
