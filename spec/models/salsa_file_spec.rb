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

require 'rails_helper'

RSpec.describe SalsaFile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
