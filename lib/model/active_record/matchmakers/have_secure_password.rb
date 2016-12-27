module ShouldaMatchmakers
  module Model
    module ActiveRecord
      module Matchmaker
        module HaveSecurePassword

          def have_secure_password_matcher_tests
            model_methods = @app_class_name.constantize.methods
            model_instance_methods = @app_class_name.constantize.instance_methods
            if model_methods.present? && model_instance_methods.present?
              generate_have_secure_password_matcher_tests(model_methods, model_instance_methods)
            else
              []
            end
         end


          private

          def generate_have_secure_password_matcher_tests(model_methods, model_instance_methods)
            secure_password_test = ""
            if model_instance_methods.include?(:password_digest) && model_methods.exclude?(:devise_parameter_filter)
              secure_password_test = "  it { is_expected.to have_secure_password }"
            end
            secure_password_test
          end

        end
      end
    end
  end
end
