require_relative 'dependencies'

class ParkingLot
  
  class << self
    attr_accessor :input_file_path, :output_file_path

    def print_welcome_message
      STDOUT.puts "Welcome to parking lot program!! You have entered interactive mode"
    end

    def message_for_command_prompt
      p '============================='
    end

    def process_input_and_display_result input
      output = 
        if input != 'exit'
          execute_command(input)
        else
          exit_program
        end
      STDOUT.puts output
    end

    def exit_loop?(input)
      %w(exit).include?(input)
    end

    def execute_command(input)
      output_message = Parking.execute_command(input)
    end

    def exit_program
      Parking.unset_current_parking
      print_thankyou_message      
    end

    def print_thankyou_message
      STDOUT.puts 'We hope you liked the program, Thanks! Bye Bye'
    end

    def detect_file_input(argument)
      return false unless argument.present?
      @input_file_path, @output_file_path = argument.split('>').collect(&:strip)
      return false unless File.exists?(input_file_path) or File.exists?(output_file_path)
    
      true
    end

    def initiate_file_mode
      Parking.read_file(input_file_path, output_file_path)
      output_file = Parking.read_file_lines(output_file_path)
      puts output_file
    end

    def initiate_interactive_mode
      begin
        message_for_command_prompt
        input = STDIN.gets.strip 
        process_input_and_display_result(input)
      end until exit_loop?(input)
    end

    def run
      print_welcome_message
      files_path_given = detect_file_input(ARGV[0])

      if files_path_given
        initiate_file_mode
      else
        initiate_interactive_mode
      end
    end
  end
end


# The program will start running on execution of the below command.
ParkingLot.run
