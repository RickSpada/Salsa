class Files::Process
  def self.call(file_name)
    new(file_name).call
  end

  def initialize(file_name)
    @file_name = file_name
  end

  def call
    raise StandardError, "File, '#{@file_name}' not found." if not File.file?(@file_name)

    # get the SalsaFile singleton and reset it
    salsa_file = SalsaFile.instance
    salsa_file.reset

    # read each line in and create a SalsaLine object for each
    line_no = 0
    File.open(@file_name).each do |line|
      line_no = line_no + 1
      line.chop! if line[-1] == "\n"
      salsa_line = SalsaLine.create({ :line_no => line_no, :text => line })
    end
    salsa_file.update_attributes(file_name: @file_name, line_count: line_no)

    # return the number of lines
    salsa_file.line_count
  end
end