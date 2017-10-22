class RemoveLines < ActiveRecord::Migration[5.1]
  def change
    remove_column :salsa_files, :lines
    add_column :salsa_files, :line_count, :integer
  end
end
