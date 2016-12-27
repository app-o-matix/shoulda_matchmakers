module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module HaveDbColumn


          def have_db_column_matcher_tests
            db_columns = @app_class_name.constantize.columns
            if db_columns.present?
              generate_have_db_column_matcher_tests(db_columns)
            else
              []
            end
          end


          private

          def generate_have_db_column_matcher_tests(db_columns)
            db_column_tests = []
            db_columns.each do |db_column|
              db_column_test = "  it { is_expected.to have_db_column(:#{ db_column.name }).of_type(:#{ db_column.type }) }"
              db_column_tests = append_element(db_column_test, db_column_tests)
            end
            format_tests(db_column_tests)
          end

        end
      end
    end
  end
end
