module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module HaveDbIndex

          def have_db_index_matcher_tests
            # IMPLEMENTATION TODO: Determine if it is possible to handle indexes where 'using=:gin' (or anything not :btree)
            db_indexes = ::ActiveRecord::Base.connection.indexes(@app_class_name.tableize.gsub("/", "_")).select{ |ndx| ndx.using == :btree }
            if db_indexes.present?
              generate_have_db_index_matcher_tests(db_indexes)
            else
              []
            end
          end


          private

          def generate_have_db_index_matcher_tests(db_indexes)
            db_index_tests = []
            db_indexes.map do |ndx|
              if ndx.columns.length == 1
                db_index_test = "  it { is_expected.to have_db_index(:#{ ndx.columns[0] })"
              else
                db_index_test = "  it { is_expected.to have_db_index(#{ ndx.columns.map { |c| c.to_sym } })"
              end
              db_index_test.concat(".unique") if ndx.unique
              db_index_test.concat(" }")
              db_index_tests = append_element(db_index_test, db_index_tests)
            end
            format_tests(db_index_tests)
          end

        end
      end
    end
  end
end
