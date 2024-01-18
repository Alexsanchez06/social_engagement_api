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

ActiveRecord::Schema[7.0].define(version: 2023_10_28_101629) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "claim_requests", force: :cascade do |t|
    t.bigint "reward_id", null: false
    t.bigint "user_id", null: false
    t.bigint "epoch_id", null: false
    t.string "quantity", default: "0", null: false
    t.string "sign", null: false
    t.string "address", null: false
    t.string "allocated_tokens", default: "0", null: false
    t.string "reference"
    t.string "status", null: false
    t.string "message"
    t.datetime "claimed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epoch_id"], name: "index_claim_requests_on_epoch_id"
    t.index ["reward_id"], name: "index_claim_requests_on_reward_id"
    t.index ["user_id", "epoch_id"], name: "index_claim_requests_on_user_id_and_epoch_id", unique: true
    t.index ["user_id"], name: "index_claim_requests_on_user_id"
  end

  create_table "epoches", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.boolean "alive", default: false, null: false
    t.string "total_points", default: "0", null: false
    t.string "total_mentions", default: "0", null: false
    t.integer "total_participants", default: 0, null: false
    t.integer "last_calculated_activity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alive"], name: "index_epoches_on_alive"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "epoch_id", null: false
    t.string "social_type", null: false
    t.string "total_activity_points", default: "0"
    t.string "total_activity_count", default: "0"
    t.string "claim_address"
    t.string "claim_status"
    t.datetime "claimed_at"
    t.string "claim_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "aggregated_points"
    t.index ["epoch_id"], name: "index_rewards_on_epoch_id"
    t.index ["user_id", "epoch_id"], name: "index_rewards_on_user_id_and_epoch_id", unique: true
    t.index ["user_id"], name: "index_rewards_on_user_id"
  end

  create_table "social_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "epoch_id", null: false
    t.string "social_type", null: false
    t.jsonb "activity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epoch_id"], name: "index_social_activities_on_epoch_id"
    t.index ["user_id", "epoch_id"], name: "index_social_activities_on_user_id_and_epoch_id"
    t.index ["user_id"], name: "index_social_activities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "social_type", null: false
    t.string "social_id", null: false
    t.string "username", null: false
    t.string "display_name"
    t.string "last_post_id"
    t.jsonb "social_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_reference"
    t.jsonb "meta_data"
    t.index ["social_id"], name: "index_users_on_social_id"
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "claim_requests", "epoches"
  add_foreign_key "claim_requests", "rewards"
  add_foreign_key "claim_requests", "users"
  add_foreign_key "rewards", "epoches"
  add_foreign_key "rewards", "users"
  add_foreign_key "social_activities", "epoches"
  add_foreign_key "social_activities", "users"
end
