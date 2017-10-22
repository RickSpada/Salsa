class Lines::Get
  def self.call(line_no)
    new(line_no).call
  end

  def initialize(line_no)
    puts ">>>>> #{line_no}"
    @line_no = line_no.to_i
  end

  def call
    # get the SalsaFile singleton
    salsa_file = SalsaFile.instance

    # raise an exception if the line number is out of bounds
    salsa_line = SalsaLine.where(line_no: @line_no)
    raise StandardError, "Line number, '#{@line_no}' is out of bounds [1, #{salsa_file.line_count}]" if
        salsa_line.blank?

    raise StandardError, 'Database is corrupt.  Reattach file to reset.' if
        salsa_line.count > 1

    salsa_line.first.text
  end
end