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

require 'rails_helper'

RSpec.describe SalsaLine, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
