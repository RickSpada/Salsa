class Files::Process
  def self.call(file_name)
    new(file_name).call
  end

  def initialize(file_name)
    @file_name = file_name
  end

  def call
    puts @file_name

    salsa = SalsaFile.instance
    salsa.file_name = @file_name

    puts salsa.file_name
  end
end