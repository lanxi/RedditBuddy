class DropRedditors < ActiveRecord::Migration
  def up
      drop_table :redditors
  end
  def down
    create_table "redditors", force: :cascade do |t|
    t.string   "name"
    t.integer  "score"
    t.integer  "subreddit_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
     end
  end
end
