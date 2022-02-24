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

ActiveRecord::Schema[7.0].define(version: 2022_02_13_052527) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wallet_transaction_items", force: :cascade do |t|
    t.bigint "wallet_transaction_id", null: false
    t.bigint "user_id", null: false
    t.integer "item_type", null: false
    t.datetime "transaction_on", null: false
    t.text "notes"
    t.json "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallet_transaction_items_on_user_id"
    t.index ["wallet_transaction_id"], name: "index_wallet_transaction_items_on_wallet_transaction_id"
  end

  create_table "wallet_transactions", force: :cascade do |t|
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.datetime "transaction_on", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallet_transactions_on_user_id"
  end

  add_foreign_key "wallet_transaction_items", "users"
  add_foreign_key "wallet_transaction_items", "wallet_transactions"
  add_foreign_key "wallet_transactions", "users"
end
