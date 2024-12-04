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

ActiveRecord::Schema[8.0].define(version: 2024_01_12_000000) do
  create_table "atoms", primary_key: "label", id: :string, force: :cascade do |t|
    t.string "creator_label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "metadata", default: {}, null: false
    t.index ["creator_label"], name: "index_atoms_on_creator_label"
    t.index ["metadata"], name: "index_atoms_on_metadata"
  end

  create_table "creators", primary_key: "label", id: :string, force: :cascade do |t|
    t.string "image", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "persons", id: false, force: :cascade do |t|
    t.string "label", null: false
    t.string "name"
    t.string "url"
    t.text "description"
    t.string "image"
    t.string "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label"], name: "index_persons_on_label", unique: true
  end

  create_table "triples", id: :string, force: :cascade do |t|
    t.string "subject_type", null: false
    t.string "subject_id", null: false
    t.string "predicate_type", null: false
    t.string "predicate_id", null: false
    t.string "object_type", null: false
    t.string "object_id", null: false
    t.string "creator_label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_label"], name: "index_triples_on_creator_label"
    t.index ["object_type", "object_id"], name: "index_triples_on_object"
    t.index ["predicate_type", "predicate_id"], name: "index_triples_on_predicate"
    t.index ["subject_type", "subject_id"], name: "index_triples_on_subject"
  end

  add_foreign_key "atoms", "creators", column: "creator_label", primary_key: "label"
  add_foreign_key "triples", "creators", column: "creator_label", primary_key: "label"
end
