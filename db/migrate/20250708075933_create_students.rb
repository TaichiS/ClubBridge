class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.integer :grade
      t.integer :class_number
      t.string :class_name
      t.integer :seat_number
      t.string :student_id
      t.string :name
      t.string :id_card_number
      t.integer :condition1
      t.integer :condition2
      t.string :condition3
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
