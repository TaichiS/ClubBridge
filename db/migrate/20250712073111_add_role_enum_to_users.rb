class AddRoleEnumToUsers < ActiveRecord::Migration[8.0]
  def change
    # 移除舊的 role 欄位（如果存在）並添加新的 enum
    remove_column :users, :role, :string if column_exists?(:users, :role)
    add_column :users, :user_role, :integer, default: 0, null: false
    add_index :users, :user_role
  end
end
