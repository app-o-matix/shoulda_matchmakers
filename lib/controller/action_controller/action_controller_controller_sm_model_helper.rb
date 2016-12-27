module ShouldaMatchmakers
  module Controller
    module ActionController
      module ActionControllerControllerSmModelHelper

        def compose_extended_app_controller_file_path(app_controller_name)
          # Rails.root.join("app", "controllers").to_s + "/" + get_controller_file_path(controller).concat(".rb")
          Rails.root.join("app", "controllers").to_s + "/" + app_controller_name.to_s.underscore.concat(".rb")
        end

        def get_app_controller_file_path(app_controller_name)
          app_controller_name.constantize.controller_path
        end

        def get_app_controller_routes_by_action(app_controller_name, app_controller_action)
          Rails.application.routes.set.select { |route| route.defaults[:controller] == app_controller_name && route.defaults[:action] == app_controller_action }
        end

        def get_app_controller_routes_by_path(app_controller_path)
          Rails.application.routes.set.select { |route| route.name == app_controller_path.to_s.chomp("_path") }
        end

        def compose_route_controller(app_controller_name)
          app_controller_name.underscore.sub(/_controller$/, "")
        end

        def get_route_http_method(route)
          route.constraints[:request_method].to_s.gsub("(?-mix:^","").gsub("$)","")
        end

        def containing_method_is_action(app_controller_name, app_controller_action_candidate)
          app_controller_name.constantize.instance_methods(false).include?(app_controller_action_candidate.to_sym)
        end

        def append_element(element, element_set)
          if element.present?
            element_set << element
          end
          element_set
        end

        def format_tests(tests)
          formatted_tests = properly_line_space_tests(tests)
          formatted_tests.flatten.compact.uniq.join("\n")
        end

        def properly_line_space_tests(tests)
          tests_properly_line_spaced = []
          previous_test = ""
          tests.each do |test|
            if (test.include?("\n") && previous_test.present?) ||
                 (!test.include?("\n") && previous_test.include?("\n"))
              test_properly_line_spaced = "\n" + test
            else
              test_properly_line_spaced = test
            end
            tests_properly_line_spaced << test_properly_line_spaced
            previous_test = test
          end
          tests_properly_line_spaced
        end

      end
    end
  end
end
