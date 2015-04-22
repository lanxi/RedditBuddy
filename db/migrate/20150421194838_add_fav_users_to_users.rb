class AddFavUsersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fav_user, :string
  end
end
