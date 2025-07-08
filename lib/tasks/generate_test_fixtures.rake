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
  end
end
