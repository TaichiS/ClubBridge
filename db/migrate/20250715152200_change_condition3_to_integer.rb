class ChangeCondition3ToInteger < ActiveRecord::Migration[8.0]
  def up
    # 先清理現有的字串資料，轉換成整數
    Student.where.not(condition3: nil).find_each do |student|
      if student.condition3.present?
        # 處理 "0.0" 這種格式
        if student.condition3.match?(/^\d+\.0*$/)
          student.update_column(:condition3, student.condition3.to_f.to_i.to_s)
        end
      end
    end
    
    Club.where.not(condition3: nil).find_each do |club|
      if club.condition3.present?
        # 處理 "0.0" 這種格式
        if club.condition3.match?(/^\d+\.0*$/)
          club.update_column(:condition3, club.condition3.to_f.to_i.to_s)
        end
      end
    end
    
    # 轉換欄位型別
    change_column :students, :condition3, :integer
    change_column :clubs, :condition3, :integer
  end
  
  def down
    # 回復成字串型別
    change_column :students, :condition3, :string
    change_column :clubs, :condition3, :string
  end
end
