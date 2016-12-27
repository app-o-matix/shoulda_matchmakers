module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module RenderTemplate


          def render_template_matcher_tests
            render_template_occurrences = get_render_template_occurrences(@app_controller_name)
            if render_template_occurrences.present?
              generate_render_template_matcher_tests(render_template_occurrences)
            else
              []
            end
          end


          private

          def get_render_template_occurrences(app_controller_name)
            render_template_occurrences = []
            app_views_path = Rails.root.join("app", "views").to_s + "/"
            app_controller_views_path = app_views_path + app_controller_name.underscore.sub(/_controller$/, "/")
            %w(erb haml slim).each do |view_file_format|
              render_template_occurrences = render_template_occurrences + get_render_template_occurrences_by_file_type(app_controller_name, app_views_path, app_controller_views_path, view_file_format)
            end
            render_template_occurrences
          end

          def get_render_template_occurrences_by_file_type(app_controller_name, app_views_path, app_controller_views_path, view_file_format)
            render_template_occurrences_by_file_type = []
            Dir.glob(app_controller_views_path + "**/*.html." + view_file_format) do |view_file_path|
              view_action_render_occurrences = parse_controller_for_view_action_render_occurrences(view_file_path, app_views_path)
              if view_action_render_occurrences.present?
                view_action = get_view_from_path(view_file_path).sub(".html." + view_file_format, "")
                if containing_method_is_action(app_controller_name, view_action)
                  render_template_occurrence_hashes = compose_render_template_occurrence_hashes(app_controller_name, view_action, view_action_render_occurrences)
                  render_template_occurrences_by_file_type = render_template_occurrences_by_file_type + render_template_occurrence_hashes
                end
              end
            end
            render_template_occurrences_by_file_type
          end

          def parse_controller_for_view_action_render_occurrences(view_file_path, app_views_path)
            view_action_render_occurrences = []
            File.open(view_file_path, 'r') do |view_file|
              view_file.each_line do |view_file_line|
                if view_file_line =~ /(?:\s+render|=render)(?:\s+action:\s+|\s+:action\s+=\>\s+|\s+file:\s+|\s+:file\s+=\>\s+|\s+partial:\s+|\s+:partial\s+=\>\s+|\s+template:\s+|\s+:template\s+=\>\s+|\s+)["':][A-Za-z0-9_\/\.]+"*'*\s*$/
                  view_action_render_occurrence = compose_view_action_render_occurrence_hash(app_views_path, view_file_path, view_file_line)
                  view_action_render_occurrences = append_element(view_action_render_occurrence, view_action_render_occurrences)
                end
              end
            end
            view_action_render_occurrences
          end

          def compose_view_action_render_occurrence_hash(app_views_path, view_file_path, view_file_line)
            render_view_type, render_view_path = view_file_line.match(/(?:\s+render|=render)(\s+action:\s+|\s+:action\s+=\>\s+|\s+file:\s+|\s+:file\s+=\>\s+|\s+partial:\s+|\s+:partial\s+=\>\s+|\s+template:\s+|\s+:template\s+=\>\s+|\s+)["':]([A-Za-z0-9_\/\.]+)/).captures
            if render_view_type.present?
              render_view_type = render_view_type.gsub(/\s+/,"").gsub(":", "").gsub("=>","")
            else
              render_view_type = get_render_view_type(app_views_path, view_file_path, render_view_path)
            end
            { render_view_type: render_view_type, render_view: render_view_path }
          end

          def compose_render_template_occurrence_hashes(app_controller_name, view_action, view_action_render_occurrences)
            render_template_occurrence_hashes = []
            app_controller_routes_controller = compose_route_controller(app_controller_name)
            view_action_routes = get_app_controller_routes_by_action(app_controller_routes_controller, view_action)
            view_action_routes.each do |view_action_route|
              view_action_http_method = get_route_http_method(view_action_route)
              render_template_occurrence_hashes << { view_action: view_action, view_action_http_method: view_action_http_method, view_action_render_occurrences: view_action_render_occurrences }
            end
            render_template_occurrence_hashes
          end

          def generate_render_template_matcher_tests(render_template_occurrences)
            render_template_tests = []
            render_template_occurrences.sort_by!{ |rto| [rto[:view_action], rto[:view_action_http_method]] }
            render_template_occurrences.each do |render_template_occurrence|
              render_template_test = generate_render_template_test_initial(render_template_occurrence)
              render_template_occurrence[:view_action_render_occurrences].sort_by!{ |varo| [varo[:render_view_type], varo[:render_view]] }
              render_template_occurrence[:view_action_render_occurrences].each do |view_action_render_occurrence|
                view_action_render_occurrence_test = generate_view_action_render_occurrence_test(view_action_render_occurrence)
                render_template_test.concat(view_action_render_occurrence_test)
              end
              render_template_test.concat("  end")
              render_template_tests = append_element(render_template_test, render_template_tests)
            end
            format_tests(render_template_tests)
          end

          def generate_render_template_test_initial(render_template_occurrence)
            render_template_test = "  describe '#{ render_template_occurrence[:view_action_http_method] } ##{ render_template_occurrence[:view_action] }' do\n"
            render_template_test.concat("    before { #{ render_template_occurrence[:view_action_http_method].downcase } :#{ render_template_occurrence[:view_action] } }\n\n")
            render_template_test.concat("    it { is_expected.to render_template('#{ render_template_occurrence[:view_action] }') }\n")
          end

          def generate_view_action_render_occurrence_test(view_action_render_occurrence)
            if view_action_render_occurrence[:render_view_type] == "partial" && view_action_render_occurrence[:render_view].include?("/") ||
                view_action_render_occurrence[:render_view_type] == "file"
              view_action_render_occurrence_test = "    it { is_expected.to render_template(#{ view_action_render_occurrence[:render_view_type] }: '"
            elsif view_action_render_occurrence[:render_view_type] == "partial"
              view_action_render_occurrence_test = "    it { is_expected.to render_template(#{ view_action_render_occurrence[:render_view_type] }: '_"
            elsif view_action_render_occurrence[:render_view_type] == "unknown"
              view_action_render_occurrence_test = "    # Unknown view type. Remove 'x' from 'xit' once view type identified (e.g. 'partial:', 'file:', etc.)\n"
              view_action_render_occurrence_test.concat("    xit { is_expected.to render_template('")
            else
              view_action_render_occurrence_test = "    it { is_expected.to render_template('"
            end
            view_action_render_occurrence_test.concat("#{ view_action_render_occurrence[:render_view] }') }\n")
          end

          def get_render_view_type(app_views_path, view_file_path, render_view_path)
            render_view_and_directory = get_internal_render_view_and_directory(app_views_path, view_file_path, render_view_path)
            render_view_type = identify_internal_render_view_type(render_view_and_directory, app_views_path)
            if render_view_type == "unknown" && render_view_path.include?("/")
              render_view_and_directory = get_external_render_view_and_directory(render_view_path)
              render_view_type = identify_external_render_view_type(render_view_and_directory)
            end
            render_view_type
          end

          def get_internal_render_view_and_directory(app_views_path, view_file_path, render_view_path)
            if render_view_path.include?("/")
              render_view_directory = get_view_directory_prepended(render_view_path,app_views_path)
              render_view = get_view_from_path(render_view_path).sub(/^\s*_/,"")
            else
              render_view_directory = get_view_directory_from_path(view_file_path)
              render_view = render_view_path.sub(/^\s*_/,"")
            end
            { directory: render_view_directory, view: render_view }
          end

          def get_external_render_view_and_directory(render_view_path)
            render_view_directory = get_view_directory_from_path(render_view_path)
            render_view = get_view_from_path(render_view_path)
            { directory: render_view_directory, view: render_view }
          end

          def get_view_from_path(view_path)
            view_path.scan(/\/([a-zA-z0-9.]+)$/).last.first
          end

          def get_view_directory_from_path(view_path)
            view_path.sub(/\/[a-zA-z0-9.]+$/,"/")
          end

          def get_view_directory_prepended(view_path, prepend_path)
            view_path.sub(/\/[a-zA-z0-9.]+$/,"/").prepend(prepend_path)
          end

          def identify_internal_render_view_type(render_view_and_directory, app_views_path)
            render_view_type = "unknown"
            if view_partial_exist(render_view_and_directory)
              render_view_type = "partial"
            elsif view_exist(render_view_and_directory)
              render_view_controller_name = get_controller_name_from_view_directory_path(render_view_and_directory[:directory], app_views_path)
              if render_view_controller_name.present? && containing_method_is_action(render_view_controller_name, render_view_and_directory[:view])
                render_view_type = "action"
              else
                render_view_type = "template"
              end
            end
            render_view_type
          end

          def identify_external_render_view_type(render_view_and_directory)
            render_view_type = "unknown"
            if view_partial_exist(render_view_and_directory) || view_exist(render_view_and_directory)
              render_view_type = "file"
            end
            render_view_type
          end

          def view_exist(render_view_and_directory)
            File.exist?(render_view_and_directory[:directory] + render_view_and_directory[:view] + ".html.erb") ||
              File.exist?(render_view_and_directory[:directory] + render_view_and_directory[:view] + ".html.haml") ||
              File.exist?(render_view_and_directory[:directory] + render_view_and_directory[:view] + ".html.slim")
          end

          def view_partial_exist(render_view_and_directory)
            File.exist?(render_view_and_directory[:directory] + "_" + render_view_and_directory[:view] + ".html.erb") ||
              File.exist?(render_view_and_directory[:directory] + "_" + render_view_and_directory[:view] + ".html.haml") ||
              File.exist?(render_view_and_directory[:directory] + "_" + render_view_and_directory[:view] + ".html.slim")
          end

          def get_controller_name_from_view_directory_path(view_directory_path, app_views_path)
            view_directory_path.sub(app_views_path, "").sub(/\/$/,"").concat("_controller").camelize
          end

        end
      end
    end
  end
end
