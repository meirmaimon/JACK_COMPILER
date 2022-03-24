# This module assist CodeWriter class with some constants and methods
module Commands
  # Translation of the arithmetic command in VM command into the action taken in HACK command
  ARITHMETIC = { "add" => "+", "sub" => "-", "neg" => "-", "eq" => "JEQ", "gt" => "JGT", "lt" => "JLT",
                 "and" => "&", "or" => "|", "not" => "!" }
  # Translation of segment in VM command to HACK command
  SEGMENT = { "local" => "LCL", "argument" => "ARG", "this" => "THIS", "that" => "THAT", "temp" => 5 }
  # Return the operation in the command
  def get_operation(command)
    command.split.first
  end

  # Return the first argument in the command
  def get_first_arg(command)
    command.split.drop(1).first
  end

  # Return the last argument in the command
  def get_last_arg(command)
    command.split.drop(1).last
  end
end
