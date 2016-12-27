module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module RenderWithLayout


          def render_with_layout_matcher_tests
            render_with_layout_occurrences = get_render_with_layout_occurrences(@app_controller_name)
            if render_with_layout_occurrences.present?
              generate_render_with_layout_matcher_tests(@app_controller_name, render_with_layout_occurrences)
            else
              []
            end
          end


          private

          def get_render_with_layout_occurrences(app_controller_name)
            render_with_layout_occurrences = []
            app_controller_file_path = compose_extended_app_controller_file_path(app_controller_name)
            if File.exists?(app_controller_file_path)
              render_with_layout_occurrences = parse_app_controller_for_render_with_layout_occurrences(app_controller_file_path)
            end
            render_with_layout_occurrences
          end

          def parse_app_controller_for_render_with_layout_occurrences(app_controller_file_path)
            render_with_layout_occurrences = []
            current_app_controller_method = nil
            File.open(app_controller_file_path, 'r') do |app_controller_file|
              app_controller_file.each_line do |app_controller_file_line|
                if app_controller_file_line =~ /\s+def\s[A-Za-z0-9_][A-Za-z0-9_!\?=]+/
                  current_app_controller_method = app_controller_file_line.scan(/\s+def\s([A-Za-z0-9_][A-Za-z0-9_!\?=]+)/).flatten.first
                elsif app_controller_file_line.include?(" render layout:")
                  render_with_layout_layout = app_controller_file_line.scan(/\s+render\slayout:\s['"]([a-z0-9_]+)/).flatten.first
                  if current_app_controller_method.present? && render_with_layout_layout.present?
                    render_with_layout_occurrences << { controller_action: current_app_controller_method, layout: render_with_layout_layout }
                  end
                end
              end
            end
            render_with_layout_occurrences
          end

          def generate_render_with_layout_matcher_tests(app_controller_name, render_with_layout_occurrences)
            render_with_layout_tests = []
            render_with_layout_occurrences.sort_by!{ |rwlo| [rwlo[:controller_action], rwlo[:layout]] }
            render_with_layout_occurrences.each do |render_with_layout_occurrence|
              app_controller_route_controller = compose_route_controller(app_controller_name)
              app_controller_action_routes = get_app_controller_routes_by_action(app_controller_route_controller, render_with_layout_occurrence[:controller_action])
              app_controller_action_routes.each do |app_controller_action_route|
                render_with_layout_test = generate_render_with_layout_test(app_controller_action_route, render_with_layout_occurrence)
                append_element(render_with_layout_test, render_with_layout_tests)
              end
            end
            format_tests(render_with_layout_tests)
          end

          def generate_render_with_layout_test(app_controller_action_route, render_with_layout_occurrence)
            app_controller_route_http_method = get_route_http_method(app_controller_action_route)
            render_with_layout_test = "  describe '#{ app_controller_route_http_method } ##{ render_with_layout_occurrence[:controller_action] }' do\n"
            render_with_layout_test.concat("    before { #{ app_controller_route_http_method.downcase } :#{ render_with_layout_occurrence[:controller_action] } }\n\n")
            render_with_layout_test.concat("    it { is_expected.to render_with_layout('#{ render_with_layout_occurrence[:layout] }') }\n  end\n")
          end

        end
      end
    end
  end
end
