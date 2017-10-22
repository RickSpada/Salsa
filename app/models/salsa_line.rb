# == Schema Information
#
# Table name: salsa_lines
#
#  id         :integer          not null, primary key
#  line_no    :integer
#  text       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SalsaLine < ApplicationRecord
end
