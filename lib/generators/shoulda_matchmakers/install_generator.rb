module ShouldaMatchmakers
  class InstallGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.dirname(__FILE__)))

    def copy_initializer
      copy_file '../../templates/shoulda_matchmakers.rb', 'config/initializers/shoulda_matchmakers.rb'
    end

  end
end
