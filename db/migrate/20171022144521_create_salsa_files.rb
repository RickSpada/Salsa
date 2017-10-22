class CreateSalsaFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :salsa_files do |t|
      t.integer :singleton_guard
      t.string :file_name

      t.timestamps
    end

    add_index(:salsa_files, :singleton_guard, :unique => true)
  end
end
