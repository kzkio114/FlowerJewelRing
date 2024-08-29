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

ActiveRecord::Schema[7.1].define(version: 2024_08_29_221909) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.integer "admin_role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_admin_users_on_organization_id"
    t.index ["user_id"], name: "index_admin_users_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chats", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.text "message"
    t.text "encrypted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_chats_on_receiver_id"
    t.index ["sender_id"], name: "index_chats_on_sender_id"
  end

  create_table "consultations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed"
    t.string "desired_reply_tone"
    t.string "display_choice"
    t.index ["category_id"], name: "index_consultations_on_category_id"
    t.index ["user_id"], name: "index_consultations_on_user_id"
  end

  create_table "gift_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.string "color"
  end

  create_table "gift_histories", force: :cascade do |t|
    t.integer "gift_id"
    t.text "sender_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false
    t.boolean "active", default: true, null: false
    t.index ["read"], name: "index_gift_histories_on_read"
  end

  create_table "gift_templates", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "image_url"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "gift_category_id"
  end

  create_table "gifts", force: :cascade do |t|
    t.bigint "giver_id"
    t.bigint "receiver_id"
    t.bigint "gift_category_id", null: false
    t.text "description"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "item_name"
    t.string "image_url"
    t.string "color"
    t.text "sender_message"
    t.integer "gift_template_id"
    t.boolean "active", default: true, null: false
    t.boolean "anonymous"
    t.index ["gift_category_id"], name: "index_gifts_on_gift_category_id"
    t.index ["giver_id"], name: "index_gifts_on_giver_id"
    t.index ["receiver_id"], name: "index_gifts_on_receiver_id"
  end

  create_table "group_chat_members", force: :cascade do |t|
    t.bigint "group_chat_id", null: false
    t.bigint "user_id", null: false
    t.integer "role"
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_chat_id"], name: "index_group_chat_members_on_group_chat_id"
    t.index ["user_id"], name: "index_group_chat_members_on_user_id"
  end

  create_table "group_chat_messages", force: :cascade do |t|
    t.bigint "group_chat_id", null: false
    t.bigint "user_id", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_chat_id"], name: "index_group_chat_messages_on_group_chat_id"
    t.index ["user_id"], name: "index_group_chat_messages_on_user_id"
  end

  create_table "group_chats", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "introduction"
    t.text "interests"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "consultation_id", null: false
    t.bigint "user_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false
    t.string "tone"
    t.string "display_choice"
    t.boolean "anonymous"
    t.index ["consultation_id"], name: "index_replies_on_consultation_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "user_organizations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_user_organizations_on_organization_id"
    t.index ["user_id"], name: "index_user_organizations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id"
    t.string "email", null: false
    t.string "password_digest"
    t.string "social_id"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "active", default: true
    t.boolean "anonymous", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "admin_users", "organizations"
  add_foreign_key "admin_users", "users"
  add_foreign_key "chats", "users", column: "receiver_id"
  add_foreign_key "chats", "users", column: "sender_id"
  add_foreign_key "consultations", "categories"
  add_foreign_key "consultations", "users"
  add_foreign_key "gifts", "gift_categories"
  add_foreign_key "gifts", "users", column: "giver_id"
  add_foreign_key "gifts", "users", column: "receiver_id"
  add_foreign_key "group_chat_members", "group_chats"
  add_foreign_key "group_chat_members", "users"
  add_foreign_key "group_chat_messages", "group_chats"
  add_foreign_key "group_chat_messages", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "replies", "consultations"
  add_foreign_key "replies", "users"
  add_foreign_key "user_organizations", "organizations"
  add_foreign_key "user_organizations", "users"
  add_foreign_key "users", "organizations"
end
