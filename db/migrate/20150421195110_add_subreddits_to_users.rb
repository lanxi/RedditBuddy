class AddSubredditsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subreddits, :string
  end
end
