# == Schema Information
#
# Table name: salsa_files
#
#  id              :integer          not null, primary key
#  singleton_guard :integer
#  file_name       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  line_count      :integer
#

class SalsaFile < ApplicationRecord
  # The "singleton_guard" column is a unique column which must always be set to '0'
  # This ensures that only one AppSettings row is created
  validates_inclusion_of :singleton_guard, :in => [0]

  def self.instance
    # there will be only one row, and its ID must be '1'
    begin
      find(1)
    rescue ActiveRecord::RecordNotFound
      # slight race condition here, but it will only happen once
      row = SalsaFile.new
      row.singleton_guard = 0
      row.save!
      row
    end
  end

  def reset
    self.file_name = nil
    self.line_count = 0
    self.save!

    # delete all SalsaLines, they're no longer valid
    SalsaLine.delete_all
  end
end
