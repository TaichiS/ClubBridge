class CreateClubSelections < ActiveRecord::Migration[8.0]
  def change
    create_table :club_selections do |t|
      t.references :student, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.integer :preference, null: false

      t.timestamps
    end

    add_index :club_selections, [:student_id, :club_id], unique: true
    add_index :club_selections, [:student_id, :preference], unique: true
  end
end
