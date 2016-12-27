module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module RedirectTo


          def redirect_to_matcher_tests
            redirect_to_occurrences = get_redirect_to_occurrences(@app_controller_name)
            if redirect_to_occurrences.present?
              generate_redirect_to_matcher_tests(@app_controller_name, redirect_to_occurrences)
            else
              []
            end
          end


          private

          def get_redirect_to_occurrences(app_controller_name)
            redirect_to_occurrences = []
            app_controller_file_path = compose_extended_app_controller_file_path(app_controller_name)
            if File.exists?(app_controller_file_path)
              redirect_to_occurrences = parse_app_controller_for_redirect_to_occurrences(app_controller_file_path)
            end
            redirect_to_occurrences
          end

          def parse_app_controller_for_redirect_to_occurrences(app_controller_file_path)
            redirect_to_occurrences = []
            File.open(app_controller_file_path, 'r') do |app_controller_file|
              current_app_controller_method = nil
              continued_from_previous_line = false
              app_controller_file.each_line do |app_controller_file_line|
                if continued_from_previous_line
                  redirect_location = app_controller_file_line.scan(/^\s+(:?[a-z0-9_]+)/).flatten.first
                  if current_app_controller_method.present? && redirect_location.present?
                    redirect_to_occurrences << { controller_action: current_app_controller_method, redirect_location: redirect_location }
                  end
                  continued_from_previous_line = false
                elsif app_controller_file_line =~ /\s+def\s[A-Za-z0-9_][A-Za-z0-9_!\?=]+/
                  current_app_controller_method = app_controller_file_line.scan(/\s+def\s([A-Za-z0-9_][A-Za-z0-9_!\?=]+)/).flatten.first
                elsif app_controller_file_line =~ /^\s+redirect_to(?:\s+|\s*\()\s*:?[a-z0-9_]+/
                  redirect_location = app_controller_file_line.scan(/^\s+redirect_to(?:\s+|\s*\()\s*(:?[a-z0-9_]+)/).flatten.first
                  if current_app_controller_method.present? && redirect_location.present?
                    redirect_to_occurrences << { controller_action: current_app_controller_method, redirect_location: redirect_location }
                  end
                elsif app_controller_file_line =~ /^\s+redirect_to(?:\s+|\s*\()\s*\n/
                  continued_from_previous_line = true
                end
              end
            end
            redirect_to_occurrences
          end

          def generate_redirect_to_matcher_tests(app_controller_name, redirect_to_occurrences)
            redirect_to_tests = []
            app_controller_route_controller = compose_route_controller(app_controller_name)
            redirect_to_occurrences.each do |redirect_to_occurrence|
              app_controller_action_routes = get_app_controller_routes_by_action(app_controller_route_controller, redirect_to_occurrence[:controller_action])
              app_controller_action_routes.each do |app_controller_action_route|
                redirect_to_test = generate_redirect_to_test(app_controller_route_controller, app_controller_action_route, redirect_to_occurrence)
                redirect_to_tests = append_element(redirect_to_test, redirect_to_tests)
              end
            end
            format_tests(redirect_to_tests)
          end

          def generate_redirect_to_test(app_controller_route_controller, app_controller_action_route, redirect_to_occurrence)
            if redirect_to_occurrence[:redirect_location] =~ /^:/
              redirect_to_action_and_path_hash = compose_redirect_to_action_and_path_hash_for_action(app_controller_route_controller, redirect_to_occurrence[:redirect_location])
            elsif redirect_to_occurrence[:redirect_location] =~ /_path$/
              redirect_to_action_and_path_hash = compose_redirect_to_action_and_path_hash_for_path(app_controller_action_route, redirect_to_occurrence[:redirect_location])
            else
              redirect_to_action_and_path_hash = { action: "", path: "" }
            end
            if redirect_to_action_and_path_hash[:action].present? || redirect_to_action_and_path_hash[:path].present?
              compose_redirect_to_test(app_controller_action_route, redirect_to_action_and_path_hash)
            else
              ""
            end
          end

          def compose_redirect_to_action_and_path_hash_for_action(app_controller_route_controller, redirect_location)
            redirect_to_action_and_path_hash = {}
            redirect_routes = get_app_controller_routes_by_action(app_controller_route_controller, redirect_location)
            redirect_to_action_and_path_hash[:action] = redirect_location
            if redirect_routes.present? && redirect_routes.first.name.present?
              redirect_to_action_and_path_hash[:path] = redirect_routes.first.name.concat("_path")
            else
              redirect_to_action_and_path_hash[:path] = ""
            end
            redirect_to_action_and_path_hash
          end

          def compose_redirect_to_action_and_path_hash_for_path(app_controller_action_route, redirect_location)
            redirect_to_action_and_path_hash = {}
            redirect_routes = get_app_controller_routes_by_path(redirect_location)
            if redirect_routes.present? && redirect_routes.first.defaults[:controller] == app_controller_action_route.defaults[:controller]
              redirect_to_action_and_path_hash[:action] = redirect_routes.first.defaults[:action]
            else
              redirect_to_action_and_path_hash[:action] = ""
            end
            redirect_to_action_and_path_hash[:path] = redirect_location
            redirect_to_action_and_path_hash
          end

          def compose_redirect_to_test(app_controller_action_route, redirect_to_action_and_path_hash)
            app_controller_route_http_method = get_route_http_method(app_controller_action_route)
            app_controller_action = app_controller_action_route.defaults[:action].to_s
            redirect_to_test = "  describe '#{ app_controller_route_http_method } ##{ app_controller_action }' do\n"
            redirect_to_test.concat("    before { #{ app_controller_route_http_method.downcase } :#{ app_controller_action } }\n\n")
            if redirect_to_action_and_path_hash[:path].present?
              redirect_to_test.concat("    it { is_expected.to redirect_to(#{ redirect_to_action_and_path_hash[:path] }) }\n")
            end
            if redirect_to_action_and_path_hash[:action].present?
              redirect_to_test.concat("    it { is_expected.to redirect_to(action: #{ redirect_to_action_and_path_hash[:action] }) }\n")
            end
            redirect_to_test.concat("  end\n")
          end

        end
      end
    end
  end
end
