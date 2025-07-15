class AddMinRequiredChoicesToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :min_required_choices, :integer
  end
end
