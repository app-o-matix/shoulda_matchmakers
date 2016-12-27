require_relative 'active_record_model_sm_model_helper'
require_relative 'factory_sm_model_helper'

module ShouldaMatchmakers
  module Model
    module ActiveRecord
      class FactorySmModel

        ### Includes ###
        include ActiveRecordModelSmModelHelper
        include FactorySmModelHelper


        ### Attribute Accessors ###
        attr_accessor :app_class_name,
                      :working_generated_code_line_length


        ### Methods ###
        def initialize(app_class_name, code_line_length)
          @app_class_name = app_class_name
          @working_generated_code_line_length = code_line_length
        end

      end
    end
  end
end
