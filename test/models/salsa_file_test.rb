# == Schema Information
#
# Table name: salsa_files
#
#  id              :integer          not null, primary key
#  singleton_guard :integer
#  file_name       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  lines           :string
#

require 'test_helper'

class SalsaFileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
