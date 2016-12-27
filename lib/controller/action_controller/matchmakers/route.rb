module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module Route


          def route_matcher_tests
            if journey_routes_present(@app_controller_name)
              generate_route_matcher_tests(@app_controller_name)
            else
              []
            end
          end


          private

          def journey_routes_present(app_controller_name)
            app_controller_journey_routes_present = false
            app_controller_path = get_app_controller_file_path(app_controller_name)
            app_controller_name.constantize.action_methods.map do |app_controller_action_method|
              app_controller_journey_routes = extract_journey_routes(app_controller_path, app_controller_action_method)
              app_controller_journey_routes_present = true if app_controller_journey_routes.present?
            end
            app_controller_journey_routes_present
          end

          def extract_journey_routes(app_controller_path, app_controller_action_method)
            Rails.application.routes.routes.routes.select do |route|
              if route.defaults.present?
                route.defaults[:controller].to_sym == app_controller_path.to_sym && route.defaults[:action].to_sym == app_controller_action_method.to_sym
              else
                false
              end
            end
          end

          def generate_route_matcher_tests(app_controller_name)
            route_tests = []
            app_controller_path = get_app_controller_file_path(app_controller_name)
            app_controller_name.constantize.action_methods.sort.each do |app_controller_action_method|
              app_controller_journey_routes = extract_journey_routes(app_controller_path, app_controller_action_method)
              app_controller_journey_routes.each do |app_controller_journey_route|
                tests_for_one_route = generate_tests_for_one_route(app_controller_journey_route)
                route_tests = route_tests + tests_for_one_route
              end
            end
            format_tests(route_tests)
          end

          def generate_tests_for_one_route(app_controller_journey_route)
            tests_for_one_route = []
            route_parameters_hash = compose_route_parameters_hash(app_controller_journey_route)
            route_url = get_route_url(app_controller_journey_route, route_parameters_hash)
            request_methods = get_request_methods(app_controller_journey_route)
            # CONFIRMATION TODO: Determine if this is the proper way to handle controller actions with multiple HTTP verbs
            request_methods.each do |request_method|
              tests_for_one_route << generate_route_test(app_controller_journey_route, route_url, request_method, route_parameters_hash)
            end
            tests_for_one_route
          end

          def compose_route_parameters_string(route_parameters_hash)
            route_parameters_string = ""
            route_parameters_hash.each do |param_key, param_value|
              if param_key.to_s == "format" && param_value == nil
                route_parameters_string.concat(", format: nil")
              else
                route_parameters_string.concat(", " + param_key.to_s + ": " + param_value.to_s)
              end
            end
            route_parameters_string
          end

          # IMPLEMENTATION TODO: Determine if possible to utilize 'regexp-examples' gem to provide values
          def add_dummy_values_to_route_parameters_with_regexp_values(parameters_hash_with_regexp_values_handled)
            parameters_hash_with_regexp_dummy_values = parameters_hash_with_regexp_values_handled
            parameters_hash_with_regexp_dummy_values.each do |param_key, param_value|
              if param_value.is_a?(Regexp)
                parameters_hash_with_regexp_dummy_values[param_key] = "'<value matching regexp required>'"
              end
            end
            parameters_hash_with_regexp_dummy_values
          end

          def add_dummy_values_to_route_parameters_with_missing_values(parameters_hash_handled, parameter_keys_with_missing_values_handled)
            parameters_hash_with_dummy_values = parameters_hash_handled
            parameter_keys_with_missing_values_handled.each do |key_with_missing_value|
              parameters_hash_with_dummy_values[key_with_missing_value] = "'<value required>'"
            end
            parameters_hash_with_dummy_values
          end

          def add_test_comment_for_route_parameters_with_regexp_values(parameters_hash_handled)
            parameters_hash_with_regexp_values_comment_added = parameters_hash_handled
            parameters_hash_with_regexp_values_comment_added.each do |param_key, param_value|
              if param_value.is_a?(Regexp)
                param_regexp_string = param_value.to_s.sub("(?-mix:","").gsub(/\)$/,"")
                if param_regexp_string.length <= 40
                  parameters_hash_with_regexp_values_comment_added[:test_comment].concat("# A required value for route parameter ':#{ param_key }' matching regexp '#{ param_regexp_string }' needs to be provided.\n")
                else
                  parameters_hash_with_regexp_values_comment_added[:test_comment].concat("# A required value for route parameter ':#{ param_key }' matching a regexp specified in routes.rb needs to be provided.\n")
                end
              end
            end
            parameters_hash_with_regexp_values_comment_added
          end

          def add_test_comment_for_route_parameters_with_missing_values(parameters_hash_with_missing_values_handled, parameter_keys_with_missing_values_handled)
            parameters_hash_with_missing_values_comment_added = parameters_hash_with_missing_values_handled
            if parameter_keys_with_missing_values_handled.size == 1
              parameters_hash_with_missing_values_comment_added[:test_comment].concat("# A required value for route parameter ':#{ parameter_keys_with_missing_values_handled[0] }' needs to be provided.\n")
            else
              parameters_hash_with_missing_values_comment_added[:test_comment].concat("# Required values for route parameters '#{ parameter_keys_with_missing_values_handled.to_s }' need to be provided.\n")
            end
            parameters_hash_with_missing_values_comment_added
          end

          def compose_route_parameters_hash(journey_route)
            route_required_parameter_keys_with_missing_values = journey_route.required_keys - journey_route.requirements.keys
            route_parameters_hash = journey_route.requirements.select { |key, value| journey_route.parts.include? key } || {}
            if special_handling_of_route_parameters_required(route_parameters_hash, route_required_parameter_keys_with_missing_values)
              route_parameters_hash = handle_route_parameters_which_require_special_handling(route_parameters_hash, route_required_parameter_keys_with_missing_values)
           end
           route_parameters_hash
          end

          def generate_route_test(journey_route, route_url, request_method, route_parameters_hash)
            route_test = generate_route_test_single_line(journey_route, route_url, request_method, route_parameters_hash)
            if route_test.length > @working_generated_code_line_length
              route_test = generate_route_test_multiple_line(route_test)
            end
            route_test
          end

          def generate_route_test_multiple_line(route_test)
            route_test.sub("it { ", "it do\n    ").gsub(").to(", ").\n      to(").gsub(/\)\s\}$/, ")\n  end")
          end

          def generate_route_test_single_line(journey_route, url, request_method, route_parameters_hash)
            test_comment = route_parameters_hash.extract!(:test_comment)[:test_comment]
            route_test = "  it { is_expected.to route(#{ request_method }, '#{ url }').to(action: #{ journey_route.defaults[:action] }"
            route_test.concat(compose_route_parameters_string(route_parameters_hash)).concat(") }")
            if test_comment.present?
              route_test.sub!("  it { ", "  xit { ").prepend(test_comment)
            end
            route_test
          end

          def get_request_methods(journey_route)
            request_method_regexp = journey_route.constraints[:request_method]
            request_method_regexp.to_s.scan(/[A-Z]+/)
          end

          def get_route_url(journey_route, route_parameters_hash)
            route_url_options_hash = { controller: journey_route.defaults[:controller], action: journey_route.defaults[:action], only_path: true }
            route_url_options_hash = route_url_options_hash.merge(route_parameters_hash)
            route_parameters_hash[:test_comment].present? ? "<url required>" : url_for(route_url_options_hash)
          end

          def handle_route_parameters_which_require_special_handling(route_parameters_hash, route_required_parameter_keys_with_missing_values)
            parameters_hash_handled = route_parameters_hash
            parameters_hash_handled[:test_comment] = ""
            parameter_keys_with_missing_values_handled = route_required_parameter_keys_with_missing_values
            # CONFIRMATION TODO: Determine if this is the proper way to handle route required ':id' parameter when value not provided
            if parameter_keys_with_missing_values_handled.include? :id
              parameters_hash_handled[:id] = 1
              parameter_keys_with_missing_values_handled.delete(:id)
            end
            if parameter_keys_with_missing_values_handled.present?
              parameters_hash_handled = handle_route_parameters_with_missing_values(parameters_hash_handled, parameter_keys_with_missing_values_handled)
            end
            if parameters_hash_handled.values.any? { |route_parameter_value| route_parameter_value.is_a?(Regexp) }
              parameters_hash_handled = handle_route_parameters_with_regexp_values(parameters_hash_handled)
            end
            parameters_hash_handled[:test_comment].concat("# Unable to determine URL without values to still be provided.\n" +
                                                          "# Remove the 'x' from 'xit' once appropriate values have been supplied.\n")
            parameters_hash_handled
          end

          def handle_route_parameters_with_regexp_values(parameters_hash_handled)
            # CONFIRMATION TODO: Determine if this is the proper way to handle route required parameters that have a regexp value provided
            parameters_hash_with_regexp_values_handled = add_test_comment_for_route_parameters_with_regexp_values(parameters_hash_handled)
            add_dummy_values_to_route_parameters_with_regexp_values(parameters_hash_with_regexp_values_handled)
          end

          def handle_route_parameters_with_missing_values(parameters_hash_handled, parameter_keys_with_missing_values_handled)
            # CONFIRMATION TODO: Determine if this is the proper way to handle route required parameters that have no value provided
            parameters_hash_with_missing_values_handled = add_dummy_values_to_route_parameters_with_missing_values(parameters_hash_handled, parameter_keys_with_missing_values_handled)
            add_test_comment_for_route_parameters_with_missing_values(parameters_hash_with_missing_values_handled, parameter_keys_with_missing_values_handled)
          end

          def special_handling_of_route_parameters_required(route_parameters_hash, route_required_parameter_keys_with_missing_values)
            route_required_parameter_keys_with_missing_values.present? ||
              route_parameters_hash.values.any? { |route_parameter_value| route_parameter_value.is_a?(Regexp) }
          end

        end
      end
    end
  end
end
