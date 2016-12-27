module ShouldaMatchmakers
  module Controller
    module ActionController
      module Matchmaker
        module SetFlash


          def set_flash_matcher_tests
            set_flash_occurrences = get_set_flash_occurrences(@app_controller_name)
            if set_flash_occurrences.present?
              generate_set_flash_matcher_tests(@app_controller_name, set_flash_occurrences)
            else
              []
            end
          end


          private

          def get_set_flash_occurrences(app_controller_name)
            app_controller_file_path = compose_extended_app_controller_file_path(app_controller_name)
            if File.exists?(app_controller_file_path)
              set_flash_occurrences = parse_controller_for_set_flash_occurrences(app_controller_name, app_controller_file_path)
            else
              set_flash_occurrences = []
            end
            set_flash_occurrences
          end

          def parse_controller_for_set_flash_occurrences(app_controller_name, app_controller_file_path)
            set_flash_occurrences = []
            current_app_controller_method = nil
            File.open(app_controller_file_path, 'r') do |app_controller_file|
              app_controller_file.each_line do |app_controller_file_line|
                flash_key_value_option = {}
                if app_controller_file_line =~ /\s+def\s[A-Za-z0-9_][A-Za-z0-9_!\?=]+/
                  current_app_controller_method = app_controller_file_line.scan(/\s+def\s([A-Za-z0-9_][A-Za-z0-9_!\?=]+)/).flatten.first
                elsif app_controller_file_line =~ /^\s+flash\[:[A-Za-z0-9_]+\]\s*=/ || app_controller_file_line =~ /^\s+flash.now\[:[A-Za-z0-9_]+\]\s*=/
                  flash_key_value_option = get_flash_key_value_option(app_controller_file_line)
                elsif app_controller_file_line =~ /^\s+set_flash_message[\s\(]\s*:[A-Za-z0-9_]+\s*,/
                  flash_key_value_option = get_set_flash_message_key_and_value(app_controller_file_line)
                end
                if current_app_controller_method.present? && containing_method_is_action(app_controller_name, current_app_controller_method) && flash_key_value_option[:flash_key].present?
                  set_flash_occurrences << { controller_action: current_app_controller_method, flash_hash: flash_key_value_option }
                end
              end
            end
            consolidate_set_flash_occurrences(set_flash_occurrences) if set_flash_occurrences.present?
          end

          def get_flash_key_value_option(app_controller_file_line)
            flash_key = ""
            flash_value = ""
            flash_option = ""
            if app_controller_file_line =~ /^\s+flash\[(:[A-Za-z0-9_]+)\]\s*=\s*('.+')(?:\s+[^(\s\?)].*$|\s*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+flash\[(:[A-Za-z0-9_]+)\]\s*=\s*('.+')(?:\s+[^(\s\?)].*$|\s*$)/).captures
            elsif app_controller_file_line =~ /^\s+flash\[(:[A-Za-z0-9_]+)\]\s*=\s*(".+")(?:\s+[^(\s\?)].*$|\s*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+flash\[(:[A-Za-z0-9_]+)\]\s*=\s*(".+")(?:\s+[^(\s\?)].*$|\s*$)/).captures
            elsif app_controller_file_line =~ /^\s+flash\[(:[A-Za-z0-9_]+)\]\s*=\s*([a-zA-Z0-9_:]+)(\s+[^(\s\?)].*$|\s*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+flash\[(:[A-Za-z0-9_]+)\]\s*=\s*([a-zA-Z0-9_:]+)(\s+[^(\s\?)].*$|\s*$)/).captures
            elsif app_controller_file_line =~ /^\s+flash\.now\[(:[A-Za-z0-9_]+)\]\s*=\s*('.+')(?:\s+[^(\s\?)].*$|\s*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+flash\.now\[(:[A-Za-z0-9_]+)\]\s*=\s*('.+')(?:\s+[^(\s\?)].*$|\s*$)/).captures
              flash_option = "now"
            elsif app_controller_file_line =~ /^\s+flash\.now\[(:[A-Za-z0-9_]+)\]\s*=\s*(".+")(?:\s+[^(\s\?)].*$|\s*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+flash\.now\[(:[A-Za-z0-9_]+)\]\s*=\s*(".+")(?:\s+[^(\s\?)].*$|\s*$)/).captures
              flash_option = "now"
            elsif app_controller_file_line =~ /^\s+flash\.now\[(:[A-Za-z0-9_]+)\]\s*=\s*([a-zA-Z0-9_:]+)(\s+[^(\s\?)].*$|\s*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+flash\.now\[(:[A-Za-z0-9_]+)\]\s*=\s*([a-zA-Z0-9_:]+)(\s+[^(\s\?)].*$|\s*$)/).captures
              flash_option = "now"
            end
            { flash_key: flash_key, flash_value: flash_value, flash_option: flash_option }
          end

          def get_set_flash_message_key_and_value(app_controller_file_line)
            flash_key = ""
            flash_value = ""
            if app_controller_file_line =~ /^\s+set_flash_message(?:\s|\(|\!\s|\!\()\s*:[A-Za-z0-9_]+,\s*'.+'\s*(?:\)\s*.*$|.*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+set_flash_message(?:\s|\(|\!\s|\!\()\s*(:[A-Za-z0-9_]+),\s*'(.+)'\s*(?:\)\s*.*$|.*$)/).captures
            elsif app_controller_file_line =~ /^\s+set_flash_message(?:\s|\(|\!\s|\!\()\s*:[A-Za-z0-9_]+,\s*".+"\s*(?:\)\s*.*$|.*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+set_flash_message(?:\s|\(|\!\s|\!\()\s*(:[A-Za-z0-9_]+),\s*"(.+)"\s*(?:\)\s*.*$|.*$)/).captures
            elsif app_controller_file_line =~ /^\s+set_flash_message(?:\s|\(|\!\s|\!\()\s*:[A-Za-z0-9_]+,\s*(?::[a-zA-Z0-9_]+|[a-zA-Z0-9_]+|"[a-zA-Z0-9_\s'{}#.]+"|'[a-zA-Z0-9_\s"{}#.]+'|:"[a-zA-Z0-9_\s'{}#.]+"|:'[a-zA-Z0-9_\s"{}#.]+')\s*(?:$|,.*$|\).*$|\s.*$)/
              flash_key, flash_value = app_controller_file_line.match(/^\s+set_flash_message(?:\s|\(|\!\s|\!\()\s*(:[A-Za-z0-9_]+),\s*(:[a-zA-Z0-9_]+|[a-zA-Z0-9_]+|"[a-zA-Z0-9_\s'{}#.]+"|'[a-zA-Z0-9_\s"{}#.]+'|:"[a-zA-Z0-9_\s'{}#.]+"|:'[a-zA-Z0-9_\s"{}#.]+')\s*(?:$|,.*$|\).*$|\s.*$)/).captures
            end
            { flash_key: flash_key, flash_value: flash_value, flash_option: "" }
          end

          def consolidate_set_flash_occurrences(set_flash_occurrences)
            consolidated_occurrences = []
            consolidated_occurrence = {}
            previous_controller_action = ""
            set_flash_occurrences.sort_by!{ |sfo| [sfo[:controller_action], sfo[:flash_hash][:flash_option], sfo[:flash_hash][:flash_key], sfo[:flash_hash][:flash_value]] }
            set_flash_occurrences.each do |set_flash_occurrence|
              if set_flash_occurrence[:controller_action] == previous_controller_action
                consolidated_occurrence[:flash_hashes] << set_flash_occurrence[:flash_hash]
              else
                consolidated_occurrences = append_element(consolidated_occurrence, consolidated_occurrences)
                consolidated_occurrence = { controller_action: set_flash_occurrence[:controller_action], flash_hashes: [set_flash_occurrence[:flash_hash]] }
                previous_controller_action = set_flash_occurrence[:controller_action]
              end
            end
            append_element(consolidated_occurrence, consolidated_occurrences)
          end

          def generate_set_flash_matcher_tests(app_controller_name, set_flash_occurrences)
            set_flash_tests = []
            set_flash_occurrences.each do |set_flash_occurrence|
              app_controller_route_controller = app_controller_name.underscore.sub(/_controller$/, "")
              app_controller_action_routes = get_app_controller_routes_by_action(app_controller_route_controller, set_flash_occurrence[:controller_action])
              if app_controller_action_routes.present?
                app_controller_action_routes.each do |app_controller_action_route|
                  set_flash_test = generate_set_flash_test(app_controller_action_route, set_flash_occurrence)
                  set_flash_tests = append_element(set_flash_test, set_flash_tests)
                end
              # else
                # set_flash_occurrence exists in non-action method
              end
            end
            format_tests(set_flash_tests)
          end

          def generate_set_flash_test(app_controller_action_route, set_flash_occurrence)
            app_controller_route_http_method = get_route_http_method(app_controller_action_route)
            set_flash_test = "  describe '#{ app_controller_route_http_method } ##{ set_flash_occurrence[:controller_action] }' do\n"
            set_flash_test.concat("    before { #{ app_controller_route_http_method.downcase } :#{ set_flash_occurrence[:controller_action] } }\n\n")
            set_flash_occurrence[:flash_hashes].each do |flash_hash|
              set_flash_test.concat("    it { is_expected.to set_flash[#{ flash_hash[:flash_key] }].to(#{ flash_hash[:flash_value] }) }\n")
              set_flash_test.sub!(" set_flash", " set_flash.now") if flash_hash[:flash_option] == "now"
            end
            set_flash_test.concat("  end")
          end

        end
      end
    end
  end
end
