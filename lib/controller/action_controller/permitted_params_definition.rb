module ShouldaMatchmakers
  module Controller
    module ActionController
      class PermittedParamsDefinition

        ### Attribute Accessors ###
        attr_accessor :calls,
                      :defining_controller,
                      :defining_method,
                      :params_array_type,
                      :params_class,
                      :params_class_controller_action,
                      :permitted_params,
                      :permitted_params_string

        def initialize(defining_controller, defining_method, params_class)
          @calls = []
          @defining_controller = defining_controller
          @defining_method = defining_method
          @params_array_type = ""
          @params_class = params_class
          @params_class_controller_action = nil
          @permitted_params = []
          @permitted_params_string = ""
        end

      end
    end
  end
end


# module ShouldaMatchmakers
#   module Controller
#     module ActionController
#       class PermittedParamsDefinition
#
#         ### Attribute Accessors ###
#         attr_accessor :calling_controller,
#                       :defining_method,
#                       :defining_method_calls,
#                       :params_class,
#                       :permitted_params,
#                       :permitted_params_string,
#                       :params_array_type
#
#         def initialize(controller, defining_method, params_class, line)
#           @calling_controller = controller
#           @defining_method = defining_method
#           @defining_method_calls = []
#           @params_class = params_class
#           @permitted_params = []
#           @permitted_params_string = line
#           @params_array_type = ""
#         end
#
#       end
#     end
#   end
# end
