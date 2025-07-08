class CreateSchools < ActiveRecord::Migration[8.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
