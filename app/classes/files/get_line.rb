class Files::GetLine
  def self.call(line_offset)
    new(line_offset).call
  end

  def initialize(line_offset)
    @line_offset = line_offset
  end

  def call
    salsa_file = SalsaFile.instance
    f = File.open(salsa_file.file_name)
    f.seek(@line_offset)
    text = f.gets
    f.close
    text.chop! if text[-1] == "\n"
    text
  end
end