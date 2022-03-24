require_relative 'CodeWriter'
# This module Create .asm from a given directory of .vm files
module Translator
  # Translate each .vm file in the directory to single .asm file
  def handle_directory(path)
    out_file_name = File.basename(path)
    file_list = Dir.entries(path).select { |file_n| File.extname(file_n) == ".vm" }
    out_file = File.open("#{path}\\#{out_file_name}.asm", "a")
    file_code_writer = CodeWriter.new(out_file)
    file_list.each { |file_name| handle_file_name("#{path}\\#{file_name}", file_code_writer) }
    out_file.close
  end

  # Translate vm file
  def handle_file_name(file_name, code_writer)
    in_file = File.open(file_name, "r")
    commands = get_commands(in_file)
    code_writer.write_commands(commands)
    in_file.close
  end

  # Return list with all the command in the given file (Exclude // and empty lines)
  def get_commands(in_file)
    IO.readlines(in_file, chomp: true).reject { |line| line.start_with?("//") or line == "" }
  end

end
