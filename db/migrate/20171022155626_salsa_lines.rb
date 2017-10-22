class SalsaLines < ActiveRecord::Migration[5.1]
  def change
    add_column :salsa_files, :lines, :string, array: true
  end
end
