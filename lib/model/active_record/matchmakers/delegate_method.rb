module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module DelegateMethod


          def delegate_method_matcher_tests
            delegate_method_occurrences = get_delegate_method_occurrences(@app_class_name)
            if delegate_method_occurrences.present?
              generate_delegate_method_matcher_tests(delegate_method_occurrences)
            else
              []
            end
          end


          private

          def get_delegate_method_occurrences(app_class_name)
            delegate_method_occurrences = []
            app_model_file_path = compose_extended_model_file_path(app_class_name)
            if File.exists?(app_model_file_path)
              File.open(app_model_file_path, 'r') do |app_model_file|
                app_model_file.each_line do |app_model_file_line|
                  if app_model_file_line =~ /^\s+delegate(?:\s*\(\s*|\s+):[A-Za-z0-9_@]+/
                    delegate_method_occurrences = delegate_method_occurrences + get_delegate_delegate_method_occurrences(app_model_file_line)
                  elsif app_model_file_line =~ /^\s+def(?:_instance)?_delegators?(?:\s*\(\s*|\s+):[A-Za-z0-9_@]+/
                    delegate_method_occurrences = delegate_method_occurrences + get_def_delegate_delegate_method_occurrences(app_model_file_line)
                  end
                end
              end
            else
              delegate_method_occurrences = []
            end
            delegate_method_occurrences
          end

          def get_delegate_delegate_method_occurrences(app_model_file_line)
            delegate_delegate_method_occurrences = []
            delegated_methods = app_model_file_line.scan(/(?:^\s+delegate(?:\s*\(\s*|\s+)|,\s*)(:[A-Za-z0-9_@]+)/).flatten
            delegate = app_model_file_line.scan(/,\s*to:\s+(:?[A-Za-z0-9_@]+)/).flatten
            if delegate.present? && delegated_methods.present?
              prefix = app_model_file_line.scan(/,\s*prefix:\s+(:?[A-Za-z0-9_@]+)/).flatten
              arguments = app_model_file_line.scan(/,\s*([A-Za-z0-9_@]+:\s+:?[A-Za-z0-9_@]+)/)
              arguments = arguments.flatten.reject{ |argument| argument =~ /^to:/ || argument =~ /^prefix:/ }
              delegated_methods.each do |delegated_method|
                delegate_method_hash = { delegate: delegate[0], method: delegated_method, prefix: "", arguments: [] }
                delegate_method_hash[:prefix] = prefix[0] if prefix.present?
                delegate_method_hash[:arguments] = arguments if arguments.present?
                delegate_delegate_method_occurrences = append_element(delegate_method_hash, delegate_delegate_method_occurrences)
              end
            end
            delegate_delegate_method_occurrences
          end

          def get_def_delegate_delegate_method_occurrences(app_model_file_line)
            def_delegate_delegate_method_occurrences = []
            delegate = app_model_file_line.scan(/^\s+def(?:_instance)?_delegators?(?:\s*\(\s*|\s+)(:[A-Za-z0-9_@]+)/).flatten
            delegated_methods = app_model_file_line.scan(/,\s*(:[A-Za-z0-9_@]+)/).flatten
            if delegate.present? && delegated_methods.present?
              delegated_methods.each do |delegated_method|
                delegate_method_hash = { delegate: delegate[0], method: delegated_method, prefix: "", arguments: [] }
                def_delegate_delegate_method_occurrences = append_element(delegate_method_hash, def_delegate_delegate_method_occurrences)
              end
            end
            def_delegate_delegate_method_occurrences
          end

          def generate_delegate_method_matcher_tests(delegate_method_occurrences)
            delegate_method_tests = []
            delegate_method_occurrences.sort_by!{ |dmo| [dmo[:method], dmo[:delegate], dmo[:prefix], dmo[:arguments]] }
            delegate_method_occurrences = delegate_method_occurrences.uniq
            delegate_method_occurrences.each do |delegate_method_occurrence|
              delegate_method_test = generate_delegate_method_test(delegate_method_occurrence)
              delegate_method_tests = append_element(delegate_method_test, delegate_method_tests)
            end
            format_tests(delegate_method_tests)
          end

          def generate_delegate_method_test(delegate_method_occurrence)
            delegate_method_test = "  it { is_expected.to delegate_method(#{ delegate_method_occurrence[:method] }).to(#{ delegate_method_occurrence[:delegate] })"
            if delegate_method_occurrence[:prefix].present?
              delegate_method_test.concat(".with_prefix(#{ delegate_method_occurrence[:prefix] })")
            end
            if delegate_method_occurrence[:arguments].present?
              delegate_method_test.concat(".with_arguments(")
              delegate_method_occurrence[:arguments].each do |delegate_method_argument|
                delegate_method_test.concat("#{ delegate_method_argument }, ")
              end
              delegate_method_test.chomp!(", ").concat(")")
            end
            delegate_method_test.concat(" }")
          end


        end
      end
    end
  end
end
