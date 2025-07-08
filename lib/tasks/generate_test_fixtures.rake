namespace :test do
  desc "Generate test fixture files"
  task generate_fixtures: :environment do
    require 'axlsx'

    # Student fixture
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: "Students") do |sheet|
      sheet.add_row [
        "年級", "班級（數字）", "班級（中文）", "座號", "學號",
        "姓名", "身分證字號", "條件一", "條件二", "條件三"
      ]
      sheet.add_row [1, 1, "忠", 1, "S1001", "張三", "A123456789", 1, 1, ""]
      sheet.add_row [1, 1, "忠", 2, "S1002", "李四", "B123456789", 2, 1, ""]
    end
    p.serialize("test/fixtures/files/students.xlsx")
    puts "Generated test/fixtures/files/students.xlsx"

    # Club fixture
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: "Clubs") do |sheet|
      sheet.add_row [
        "類別", "編號", "社團名稱", "指導老師", "簡介", "最大人數",
        "上課地點", "雨天地點", "備註", "條件一", "條件二", "條件三", "社團老師 Email"
      ]
      sheet.add_row [
        "體育", "C101", "籃球社", "王老師", "一起來打籃球", 20,
        "體育館", "體育館", "", 1, 0, "", "teacher.wang@example.com"
      ]
      sheet.add_row [
        "學術", "C102", "圍棋社", "李老師", "一起來下圍棋", 10,
        "活動中心", "活動���心", "", 0, 0, "", "teacher.li@example.com"
      ]
    end
    p.serialize("test/fixtures/files/clubs.xlsx")
    puts "Generated test/fixtures/files/clubs.xlsx"
  end
end
