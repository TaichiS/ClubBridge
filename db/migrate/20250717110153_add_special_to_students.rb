class AddSpecialToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :special, :integer, default: 0
  end
end
