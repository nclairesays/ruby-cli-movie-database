class AddPasswordFlagAndDeletedFlagToUsersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :password_flag, :bool
  end
end
