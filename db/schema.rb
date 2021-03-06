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

ActiveRecord::Schema.define(version: 20170223145326) do

  create_table "lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description",        limit: 65535
    t.string   "mailbox"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "private",                          default: false
    t.string   "subject_prefix"
    t.boolean  "archive_disabled",                 default: false
    t.boolean  "disabled",                         default: false
    t.string   "message_footer"
    t.text     "custom_footer_text", limit: 65535
    t.string   "send_replies_to"
    t.string   "permitted_to_post"
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "topic_id"
    t.string   "subject"
    t.text     "body",          limit: 65535
    t.integer  "subscriber_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["subscriber_id"], name: "index_messages_on_subscriber_id", using: :btree
    t.index ["topic_id"], name: "index_messages_on_topic_id", using: :btree
  end

  create_table "servers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscribers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "email"
    t.string   "public_key"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "password_hash"
    t.string   "password_salt"
    t.boolean  "admin",         default: false
    t.boolean  "disabled",      default: false
    t.boolean  "plain_text",    default: false
  end

  create_table "subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "subscriber_id"
    t.integer  "list_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["list_id"], name: "index_subscriptions_on_list_id", using: :btree
    t.index ["subscriber_id"], name: "index_subscriptions_on_subscriber_id", using: :btree
  end

  create_table "topics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "list_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "key"
    t.index ["list_id"], name: "index_topics_on_list_id", using: :btree
  end

end
