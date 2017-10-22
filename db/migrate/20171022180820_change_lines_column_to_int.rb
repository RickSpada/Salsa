class ChangeLinesColumnToInt < ActiveRecord::Migration[5.1]
  def change
    change_column :salsa_files, :lines, :integer, array: true
  end
end
