require_relative 'matchmakers/accept_nested_attributes_for'
require_relative 'matchmakers/allow_value'
require_relative 'matchmakers/associations'
require_relative 'matchmakers/define_enum_for'
require_relative 'matchmakers/delegate_method'
require_relative 'matchmakers/have_db_column'
require_relative 'matchmakers/have_db_index'
require_relative 'matchmakers/have_readonly_attribute'
require_relative 'matchmakers/have_secure_password'
require_relative 'matchmakers/serialize'
require_relative 'matchmakers/validations'
require_relative 'active_record_model_sm_model_helper'


module ShouldaMatchmakers
  module Model
    module ActiveRecord
      class ActiveRecordModelSmModel

        ### Includes ###
        include Matchmaker::AllowValue
        include Matchmaker::Associations
        include Matchmaker::AcceptNestedAttributesFor
        include Matchmaker::DefineEnumFor
        include Matchmaker::DelegateMethod
        include Matchmaker::HaveDbColumn
        include Matchmaker::HaveDbIndex
        include Matchmaker::HaveReadonlyAttribute
        include Matchmaker::HaveSecurePassword
        include Matchmaker::Serialize
        include Matchmaker::Validations
        include ActiveRecordModelSmModelHelper


        ### Attribute Accessors ###
        attr_accessor :app_class_name,
                      :working_generated_code_line_length


        ### Methods ###
        def initialize(app_class_name, app_active_record_descendants_names, code_line_length)
          @app_class_name = app_class_name
          @app_active_record_descendants_names = app_active_record_descendants_names
          @working_generated_code_line_length = code_line_length
        end

      end
    end
  end
end
