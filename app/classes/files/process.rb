class Files::Process
  def self.call(file_name)
    raise StandardError, "File, '#{file_name}' not found." if not File.file?(@file_name)

    Thread.new { new(file_name).call }
  end

  def initialize(file_name)
    @file_name = file_name
  end

  def call
    # get the SalsaFile singleton and reset it
    salsa_file = SalsaFile.instance
    salsa_file.reset

    salsa_file.update_attributes(file_name: @file_name)

    # read each line in and create a SalsaLine object for each
    line_no = 0
    File.open(@file_name).each do |line|
      line_no = line_no + 1
      line.chop! if line[-1] == "\n"
      salsa_line = SalsaLine.create({ :line_no => line_no, :text => line })
      salsa_file.update_attributes(line_count: line_no)
    end

    # return the number of lines
    salsa_file.line_count
  end
end