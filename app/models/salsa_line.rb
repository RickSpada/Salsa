# == Schema Information
#
# Table name: salsa_lines
#
#  id          :integer          not null, primary key
#  line_no     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  line_offset :integer
#

class SalsaLine < ApplicationRecord
end
