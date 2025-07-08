class CreateClubs < ActiveRecord::Migration[8.0]
  def change
    create_table :clubs do |t|
      t.string :category
      t.string :club_number
      t.string :name
      t.string :teacher_name
      t.text :description
      t.integer :max_members
      t.string :location
      t.string :rainy_day_location
      t.text :note
      t.integer :condition1
      t.integer :condition2
      t.string :condition3
      t.string :teacher_email
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
