require_relative 'matchmakers/callbacks'
require_relative 'matchmakers/filter_param'
require_relative 'matchmakers/permit'
require_relative 'matchmakers/redirect_to'
require_relative 'matchmakers/render_template'
require_relative 'matchmakers/render_with_layout'
require_relative 'matchmakers/rescue_from'
require_relative 'matchmakers/respond_with'
require_relative 'matchmakers/route'
require_relative 'matchmakers/set_flash'
require_relative 'matchmakers/set_session'
require_relative 'action_controller_controller_sm_model_helper'

module ShouldaMatchmakers
  module Controller
    module ActionController
      class ActionControllerControllerSmModel

        ### Includes ###
        include Rails.application.routes.url_helpers
        include ActionDispatch::Routing

        include Matchmaker::Callbacks
        include Matchmaker::FilterParam
        include Matchmaker::Permit
        include Matchmaker::RedirectTo
        include Matchmaker::RenderTemplate
        include Matchmaker::RenderWithLayout
        include Matchmaker::RespondWith
        include Matchmaker::RescueFrom
        include Matchmaker::Route
        include Matchmaker::SetFlash
        include Matchmaker::SetSession
        include ActionControllerControllerSmModelHelper


        ### Attribute Accessors ###
        attr_accessor :app_controller_name,
                      :working_generated_code_line_length


        ### Methods ###
        def initialize(app_controller_name, app_action_controller_descendants_names, code_line_length)
          @app_controller_name = app_controller_name
          @app_action_controller_descendants_names = app_action_controller_descendants_names
          @working_generated_code_line_length = code_line_length
        end

      end
    end
  end
end

