class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string, null: false, default: 'school_user'
  end
end
