class SchoolSetting < ApplicationRecord
  belongs_to :school
  acts_as_tenant :school

  validates :school_id, uniqueness: true

  # 為前端提供期望的欄位名稱別名
  def registration_start_date
    enrollment_start_time
  end

  def registration_end_date
    enrollment_end_time
  end

  def assignment_date
    result_publication_start_time
  end

  # 添加前端期望的布爾值欄位
  def is_registration_open
    return false unless enrollment_start_time && enrollment_end_time
    
    now = Time.current
    now >= enrollment_start_time && now <= enrollment_end_time
  end

  def max_choices
    3 # 預設最大志願數，將來可以設為可配置
  end

  def allow_change_after_submit
    true # 預設允許修改，將來可以設為可配置
  end

  def settings_data
    {} # 預留給未來的額外設定
  end

  # 自訂 JSON 序列化
  def as_json(options = {})
    super(options).merge({
      'registration_start_date' => registration_start_date,
      'registration_end_date' => registration_end_date,
      'assignment_date' => assignment_date,
      'is_registration_open' => is_registration_open,
      'max_choices' => max_choices,
      'allow_change_after_submit' => allow_change_after_submit,
      'settings_data' => settings_data
    })
  end
end
