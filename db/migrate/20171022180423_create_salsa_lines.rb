class CreateSalsaLines < ActiveRecord::Migration[5.1]
  def change
    create_table :salsa_lines do |t|
      t.integer :line_no
      t.string :text

      t.timestamps
    end
  end
end
