class RemoveTextFromSalsaLine < ActiveRecord::Migration[5.1]
  def change
    remove_column :salsa_lines, :text, :string
    add_column :salsa_lines, :line_offset, :integer
  end
end
