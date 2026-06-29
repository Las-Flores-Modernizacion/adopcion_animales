# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_29_140223) do
  create_table "accounts", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "provider"
    t.string "uid"
    t.string "oauth_token"
    t.string "oauth_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_accounts_on_email_address", unique: true
  end

  create_table "animals", force: :cascade do |t|
    t.string "color", null: false
    t.integer "size", null: false
    t.boolean "aggressive", null: false
    t.string "unique_detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_hurt", null: false
    t.boolean "urgent"
    t.string "answer_to_name"
    t.integer "species", null: false
    t.boolean "is_anxious", null: false
    t.integer "age"
    t.string "race"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sessions_on_account_id"
  end

  add_foreign_key "sessions", "accounts"
end
