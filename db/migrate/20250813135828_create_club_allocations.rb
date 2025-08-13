class CreateClubAllocations < ActiveRecord::Migration[8.0]
  def change
    create_table :club_allocations do |t|
      t.references :student, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.integer :preference, null: false

      t.timestamps
    end

    # 添加複合索引提升查詢效能
    add_index :club_allocations, [:school_id, :student_id, :preference], 
              unique: true, name: 'index_club_allocations_on_student_preference'
    add_index :club_allocations, [:school_id, :club_id, :preference], 
              name: 'index_club_allocations_on_club_preference'
    add_index :club_allocations, [:school_id, :student_id, :club_id], 
              unique: true, name: 'index_club_allocations_on_student_club'
  end
end
