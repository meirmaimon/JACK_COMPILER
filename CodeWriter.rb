require_relative 'Commands'
# This class Translate vm command to HACK machine commands
class CodeWriter
  include Commands

  def initialize(out_file)
    @out_file = out_file
    @label_counter = 0
    @label_file_name = File.basename(out_file, ".")
  end

  # Translate the given commands into HACK command
  def write_commands(commands)
    commands.each { |command| @out_file.puts write_command(command) }
  end

  # Translate the given command into HACK command
  def write_command(command)
    op = get_operation(command)
    case op
    when "add", "sub", "and", "or"
      handle_binary_operator(op)
    when "neg", "not"
      handle_unary_operator(op)
    when "eq", "lt", "gt"
      handle_arithmetic_comparison(op)
    when "push"
      handle_push(get_first_arg(command), get_last_arg(command).to_i)
    when "pop"
      handle_pop(get_first_arg(command), get_last_arg(command).to_i)
    else
      "ERROR"
    end
  end

  # Returns translation for binary arithmetic operator  +,- ,&,|
  def handle_binary_operator(op)
    command_translation = <<~END
      @SP
      A = M-1
      D = M
      A = A-1
      M = M#{Commands::ARITHMETIC[op]}D
      @SP
      M = M-1
    END
    command_translation
  end

  # Return translation for unary arithmetic operator neg,not
  def handle_unary_operator(op)
    command_translation = <<~END
      @SP
      A = M-1
      M = #{Commands::ARITHMETIC[op]}M
    END
    command_translation
  end

  # Returns translation for arithmetic comparison of the the top stack var
  # Handles GT,LT,EQ command
  def handle_arithmetic_comparison(op)
    command_translation = <<~END
      @SP
      A = M-1
      D = M
      A = A-1
      D = M-D
      @IF_TRUE#{@label_counter}
      D;#{Commands::ARITHMETIC[op]}
      D = 0
      @SP
      A = M-1
      A = A-1
      M = D
      @IF_FALSE#{@label_counter}
      0;JMP
      (IF_TRUE#{@label_counter})
      D = -1
      @SP
      A = M-1
      A = A-1
      M = D
      (IF_FALSE#{@label_counter})
      @SP
      M = M-1
    END
    @label_counter += 1
    command_translation
  end

  # Push on the stack the value of given segment at given offset
  def handle_push(segment, offset)
    case segment
    when "constant"
      command_translation = <<~END
        @#{offset}
        D = A
        @SP
        A = M
        M = D
        @SP
        M = M + 1
      END
      command_translation
    when "local", "argument", "this", "that"
      command_translation = <<~END
        @#{offset}
        D = A
        @#{Commands::SEGMENT[segment]}
        A = M + D
        D = M
        @SP
        A = M
        M = D
        @SP
        M = M + 1
      END
      command_translation
    when "temp"
      command_translation = <<~END
        @#{Commands::SEGMENT[segment] + offset}
        D = M
        @SP
        A = M
        M = D
        @SP
        M = M + 1
      END
      command_translation
    when "pointer"
      real_seg = ""
      if offset == 0
        real_seg = "THIS"
      elsif offset == 1
        real_seg = "THAT"
      end
      command_translation = <<~END
        @#{real_seg}
        D = M
        @SP
        A = M
        M = D
        @SP
        M = M + 1
      END
      command_translation
    when "static"
      command_translation = <<~END
        @#{@label_file_name}.#{offset}
        D = M
        @SP
        A = M
        M = D
        @SP
        M = M + 1
      END
      command_translation
    else
      "ERROR"
    end
  end

  # Pop the the value on the stack to a given segment and offset
  def handle_pop(segment, offset)
    case segment
    when "local", "argument", "this", "that"
      command_translation = <<~END
        @SP
        A = M - 1
        D = M
        @#{Commands::SEGMENT[segment]}
        A = M
      END
      (1..offset).each { |_| command_translation << "A = A + 1\n" }
      command_translation << "M=D\n@SP\nM = M-1"
      command_translation
    when "temp"
      command_translation = <<~END
        @SP
        A = M - 1
        D = M
        @#{Commands::SEGMENT[segment] + offset}
        M = D
        @SP
        M = M-1
      END
      command_translation
    when "pointer"
      real_seg = ""
      if offset == 0
        real_seg = "THIS"
      elsif offset == 1
        real_seg = "THAT"
      end
      command_translation = <<~END
        @SP
        A = M - 1
        D = M
        @#{real_seg}
        M = D
        @SP
        M = M - 1
      END
      command_translation
    when "static"
      command_translation = <<~END
        @SP
        A = M - 1
        D = M
        @#{@label_file_name}.#{offset}
        M = D
        @SP 
        M = M - 1
      END
      command_translation
    else
      "ERROR"
    end
  end

end