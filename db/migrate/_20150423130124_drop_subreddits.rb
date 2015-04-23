class DropSubreddits < ActiveRecord::Migration
 def up
    drop_table :subreddits
  end

  def down
    create_table "subreddits", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
     end
  end
end
