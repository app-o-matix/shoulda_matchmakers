module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module SetSession


          def set_session_matcher_tests
            set_session_occurrences = get_set_session_occurrences(@app_controller_name)
            if set_session_occurrences.present?
              generate_set_session_matcher_tests(@app_controller_name, set_session_occurrences)
            else
              []
            end
          end


          private

          def get_set_session_occurrences(app_controller_name)
            app_controller_file_path = compose_extended_app_controller_file_path(app_controller_name)
            if File.exists?(app_controller_file_path)
              set_session_occurrences = parse_controller_for_set_session_occurrences(app_controller_name, app_controller_file_path)
              if set_session_occurrences.present?
                set_session_occurrences = consolidate_set_session_occurrences(set_session_occurrences)
              end
            else
              set_session_occurrences = []
            end
            set_session_occurrences
          end

          def parse_controller_for_set_session_occurrences(app_controller_name, app_controller_file_path)
            set_session_occurrences = []
            current_app_controller_method = nil
            File.open(app_controller_file_path, 'r') do |app_controller_file|
              app_controller_file.each_line do |app_controller_file_line|
                session_key_and_value = {}
                if app_controller_file_line =~ /\s+def\s[A-Za-z0-9_][A-Za-z0-9_!\?=]+/
                  current_app_controller_method = app_controller_file_line.scan(/\s+def\s([A-Za-z0-9_][A-Za-z0-9_!\?=]+)/).flatten.first
                elsif app_controller_file_line =~ /^\s+session\[:[A-Za-z0-9_]+\]\s*=/
                  session_key_and_value = get_session_key_and_value(app_controller_file_line)
                end
                if current_app_controller_method.present? && session_key_and_value[:session_key].present?
                  if containing_method_is_action(app_controller_name, current_app_controller_method)
                    set_session_occurrences << { controller_action: current_app_controller_method, session_hash: session_key_and_value }
                  end
                end
              end
            end
            set_session_occurrences
          end

          def get_session_key_and_value(app_controller_file_line)
            session_key = ""
            session_value = ""
            if app_controller_file_line =~ /^\s+session\[(:[A-Za-z0-9_]+)\]\s*=\s*('.+')(?:\s+[^(\s\?)].*$|\s*$)/
              session_key, session_value = app_controller_file_line.match(/^\s+session\[(:[A-Za-z0-9_]+)\]\s*=\s*('.+')(?:\s+[^(\s\?)].*$|\s*$)/).captures
            elsif app_controller_file_line =~ /^\s+session\[(:[A-Za-z0-9_]+)\]\s*=\s*(".+")(?:\s+[^(\s\?)].*$|\s*$)/
              session_key, session_value = app_controller_file_line.match(/^\s+session\[(:[A-Za-z0-9_]+)\]\s*=\s*(".+")(?:\s+[^(\s\?)].*$|\s*$)/).captures
            elsif app_controller_file_line =~ /^\s+session\[(:[A-Za-z0-9_]+)\]\s*=\s*([a-zA-Z0-9_:]+)(\s+[^(\s\?)].*$|\s*$)/
              session_key, session_value = app_controller_file_line.match(/^\s+session\[(:[A-Za-z0-9_]+)\]\s*=\s*([a-zA-Z0-9_:]+)(\s+[^(\s\?)].*$|\s*$)/).captures
            end
            { session_key: session_key, session_value: session_value }
          end

          def consolidate_set_session_occurrences(set_session_occurrences)
            consolidated_occurrences = []
            consolidated_occurrence = {}
            previous_controller_action = ""
            set_session_occurrences.sort_by!{ |sso| [sso[:controller_action], sso[:session_hash][:session_key], sso[:session_hash][:session_value]] }
            set_session_occurrences.each do |set_session_occurrence|
              if set_session_occurrence[:controller_action] == previous_controller_action
                consolidated_occurrence[:session_hashes] << set_session_occurrence[:session_hash]
              else
                consolidated_occurrences = append_element(consolidated_occurrence, consolidated_occurrences)
                consolidated_occurrence = { controller_action: set_session_occurrence[:controller_action], session_hashes: [set_session_occurrence[:session_hash]] }
                previous_controller_action = set_session_occurrence[:controller_action]
              end
            end
            append_element(consolidated_occurrence, consolidated_occurrences)
          end

          def generate_set_session_matcher_tests(app_controller_name, set_session_occurrences)
            set_session_tests = []
            set_session_occurrences.each do |set_session_occurrence|
              app_controller_route_controller = app_controller_name.underscore.sub(/_controller$/, "")
              app_controller_action_routes = get_app_controller_routes_by_action(app_controller_route_controller, set_session_occurrence[:controller_action])
              if app_controller_action_routes.present?
                app_controller_action_routes.each do |app_controller_action_route|
                  set_session_test = generate_set_session_test(app_controller_action_route, set_session_occurrence)
                  set_session_tests << set_session_test
                end
              # else
                # set_session_occurrence exists in non-action method
              end
            end
            format_tests(set_session_tests)
          end

          def generate_set_session_test(app_controller_action_route, set_session_occurrence)
            app_controller_route_http_method = get_route_http_method(app_controller_action_route)
            set_session_test = "  describe '#{ app_controller_route_http_method } ##{ set_session_occurrence[:controller_action] }' do\n"
            set_session_test.concat("    before { #{ app_controller_route_http_method.downcase } :#{ set_session_occurrence[:controller_action] } }\n\n")
            set_session_occurrence[:session_hashes].each do |session_hash|
              set_session_test.concat("    it { is_expected.to set_session[#{ session_hash[:session_key] }].to(#{ session_hash[:session_value] }) }\n")
            end
            set_session_test.concat("  end")
          end

        end
      end
    end
  end
end
