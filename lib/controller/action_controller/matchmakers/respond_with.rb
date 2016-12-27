module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module RespondWith


          def respond_with_matcher_tests
            respond_with_occurrences = get_respond_with_occurrences(@app_controller_name)
            if respond_with_occurrences.present?
              generate_respond_with_matcher_tests(@app_controller_name, respond_with_occurrences)
            else
              []
            end
          end


          private

          def get_respond_with_occurrences(app_controller_name)
            respond_with_occurrences = []
            app_controller_file_path = compose_extended_app_controller_file_path(app_controller_name)
            if File.exists?(app_controller_file_path)
              respond_with_occurrences = parse_app_controller_for_respond_with_occurrences(app_controller_file_path)
            end
            respond_with_occurrences
          end

          def parse_app_controller_for_respond_with_occurrences(app_controller_file_path)
            respond_with_occurrences = []
            current_app_controller_method = nil
            File.open(app_controller_file_path, 'r') do |app_controller_file|
              app_controller_file.each_line do |app_controller_file_line|
                if app_controller_file_line =~ /\s+def\s[A-Za-z0-9_][A-Za-z0-9_!\?=]+/
                  current_app_controller_method = app_controller_file_line.scan(/\s+def\s([A-Za-z0-9_][A-Za-z0-9_!\?=]+)/).flatten.first
                elsif app_controller_file_line.include?(" render status: ")
                  status_code = app_controller_file_line.scan(/\s+render\sstatus:\s+([0-9:][a-z0-9_]+)/).flatten.first
                  if current_app_controller_method.present? && status_code.present?
                    respond_with_occurrences << { controller_action: current_app_controller_method, status_code: status_code }
                  end
                end
              end
            end
            respond_with_occurrences
          end

          def generate_respond_with_matcher_tests(app_controller_name, respond_with_occurrences)
            respond_with_tests = []
            respond_with_occurrences.each do |respond_with_occurrence|
              app_controller_route_controller = compose_route_controller(app_controller_name)
              app_controller_action_routes = get_app_controller_routes_by_action(app_controller_route_controller, respond_with_occurrence[:controller_action])
              app_controller_action_routes.each do |app_controller_action_route|
                respond_with_test = generate_respond_with_test(app_controller_action_route, respond_with_occurrence)
                respond_with_tests = append_element(respond_with_test, respond_with_tests)
              end
            end
            format_tests(respond_with_tests)
          end

          def generate_respond_with_test(app_controller_action_route, respond_with_occurrence)
            app_controller_route_http_method = get_route_http_method(app_controller_action_route)
            respond_with_test = "  describe '#{ app_controller_route_http_method } ##{ respond_with_occurrence[:controller_action] }' do\n"
            respond_with_test.concat("    before { #{ app_controller_route_http_method.downcase } :#{ respond_with_occurrence[:controller_action] } }\n\n")
            respond_with_test.concat("    it { is_expected.to respond_with(#{ respond_with_occurrence[:status_code] }) }\n  end\n")
          end

        end
      end
    end
  end
end
