class CreateClubMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :club_memberships do |t|
      t.references :student, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.datetime :assigned_at, null: false
      t.integer :allocation_round
      t.string :assignment_type, null: false

      t.timestamps
    end

    # 添加索引
    add_index :club_memberships, [:school_id, :student_id], 
              unique: true, name: 'index_club_memberships_on_student'
    add_index :club_memberships, [:school_id, :club_id], 
              name: 'index_club_memberships_on_club'
    add_index :club_memberships, [:school_id, :assignment_type], 
              name: 'index_club_memberships_on_assignment_type'
  end
end
