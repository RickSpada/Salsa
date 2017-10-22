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
    salsa = SalsaFile.instance
    salsa.reset

    # read in each line into the singleton's 'lines' attribute
    lines = []
    File.open(@file_name, 'r').each { |line| lines << line }
    salsa.update_attributes(file_name: @file_name, lines: lines)

    # return the number of lines
    salsa.lines.length
  end
end