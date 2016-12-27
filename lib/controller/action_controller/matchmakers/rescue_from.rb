module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module RescueFrom


          def rescue_from_matcher_tests
            rescue_from_occurrences = get_rescue_from_occurrences(@app_controller_name)
            if rescue_from_occurrences.present?
              generate_rescue_from_matcher_tests(rescue_from_occurrences)
            else
              []
            end
          end


          private

          def get_rescue_from_occurrences(app_controller_name)
            rescue_from_occurrences = []
            app_controller_file_path = compose_extended_app_controller_file_path(app_controller_name)
            if File.exists?(app_controller_file_path)
              rescue_from_occurrences = parse_app_controller_for_rescue_from_occurrences(app_controller_file_path)
            end
            rescue_from_occurrences
          end

          def parse_app_controller_for_rescue_from_occurrences(app_controller_file_path)
            rescue_from_occurrences = []
            rescue_from_occurrence = {}
            continued_from_previous_line = false
            File.open(app_controller_file_path, 'r') do |app_controller_file|
              app_controller_file.each_line do |app_controller_file_line|
                if continued_from_previous_line
                  if app_controller_file_line =~ /^\s*with:\s+[A-Za-z0-9:_]+\s*$/
                    rescue_from_handler = app_controller_file_line.scan(/^\s*with:\s+([A-Za-z0-9:_]+)/).flatten.first
                    rescue_from_occurrence[:handler] = rescue_from_handler
                    rescue_from_occurrences << rescue_from_occurrence
                    rescue_from_occurrence = {}
                    continued_from_previous_line = false
                  elsif !app_controller_file_line =~ /\s*\n/
                    rescue_from_occurrence[:handler] = ":unidentified_rescue_from_handler"
                    rescue_from_occurrences << rescue_from_occurrence
                    rescue_from_occurrence = {}
                    continued_from_previous_line = false
                  end
                elsif app_controller_file_line =~ /^\s+rescue_from(?:\s+|\s*\()[A-Za-z0-9:]+\s*\)?,\s*with:\s+[A-Za-z0-9:_]+\s*$/
                  rescue_from_exception, rescue_from_handler = app_controller_file_line.match(/^\s+rescue_from(?:\s+|\s*\()([A-Za-z0-9:]+)\s*\)?,\s*with:\s+([A-Za-z0-9:_]+)/).captures
                  rescue_from_occurrence = { exception: rescue_from_exception, handler: rescue_from_handler }
                  rescue_from_occurrences << rescue_from_occurrence
                  rescue_from_occurrence = {}
                  continued_from_previous_line = false
                elsif app_controller_file_line =~ /^\s+rescue_from(?:\s+|\s*\()[A-Za-z0-9:]+\s*\)?,\s*$/
                  rescue_from_exception = app_controller_file_line.scan(/^\s+rescue_from(?:\s+|\s*\()([A-Za-z0-9:]+)/).flatten.first
                  rescue_from_occurrence = { exception: rescue_from_exception }
                  continued_from_previous_line = true
                elsif app_controller_file_line =~ /\s+rescue_from(?:\s+|\s*\()[A-Za-z0-9:]+\s*\)?/
                  rescue_from_exception = app_controller_file_line.scan(/^\s+rescue_from(?:\s+|\s*\()([A-Za-z0-9:]+)/).flatten.first
                  rescue_from_occurrence = { exception: rescue_from_exception, handler: ":unidentified_rescue_from_handler" }
                  rescue_from_occurrences << rescue_from_occurrence
                  rescue_from_occurrence = {}
                  continued_from_previous_line = false
                end
              end
            end
            rescue_from_occurrences
          end

          def generate_rescue_from_matcher_tests(rescue_from_occurrences)
            rescue_from_tests = []
            rescue_from_occurrences.each do |rescue_from_occurrence|
              rescue_from_test = generate_rescue_from_test(rescue_from_occurrence)
              rescue_from_tests = append_element(rescue_from_test, rescue_from_tests)
            end
            format_tests(rescue_from_tests)
          end

          def generate_rescue_from_test(rescue_from_occurrence)
            if rescue_from_occurrence[:handler] == ":unidentified_rescue_from_handler"
              rescue_from_test = "# A rescue_from occurrence contains complexities that make it difficult for ShouldaMatchmakers to parse completely.\n"
              rescue_from_test.concat("# Examine the rescue_from occurrence for '#{ rescue_from_occurrence[:exception] }' to determine the appropriate\n")
              rescue_from_test.concat("# syntax for the test and any required values, such as ':unidentified_rescue_from_handler' below.\n")
              rescue_from_test.concat("# Remove 'x' from 'xit' once the proper syntax has been established and required values have been provided.\n")
              rescue_from_test.concat("  xit do\n    is_expected.to rescue_from(#{ rescue_from_occurrence[:exception] }).\n")
            else
              rescue_from_test = "  it do\n    is_expected.to rescue_from(#{ rescue_from_occurrence[:exception] }).\n"
            end
            rescue_from_test.concat("      with(#{ rescue_from_occurrence[:handler] })\n  end\n")
          end

        end
      end
    end
  end
end
