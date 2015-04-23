class CreateRedditors < ActiveRecord::Migration
  def change
    create_table :redditors do |t|
      t.string :name
      t.string :subreddit
      t.integer :score

      t.timestamps null: false
    end
  end
end
