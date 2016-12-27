$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "shoulda_matchmakers/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "shoulda_matchmakers"
  spec.version = ShouldaMatchmakers::VERSION
  spec.authors = ["Tim Edwards"]
  spec.email = ["appomatix.software@gmail.com"]
  spec.homepage = "https://github.com/app-o-matix/shoulda_matchmakers"
  spec.summary = "Generates regression specs using Shoulda Matchers"
  spec.description = <<-EOF
    Shoulda Matchmakers generates regression specs for existing ActiveRecord models and ActionController controllers
    using Shoulda Matchers. It generates specs for model validations, associations, nested attributes, enum definitions,
    attribute serialization, database columns and database indexes as well as controller REST routes, and
    before/after/around actions/filters. It can also generate FactoryGirl factories containing the minimum attributes
    required for the factory to create a valid object.

    Shoulda Matchmakers is based on the Regressor gem by Erwin Schens.
  EOF
  spec.license = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  spec.add_dependency 'shoulda-matchers', '~> 3.1', '>= 3.1.1'
  spec.add_dependency 'rails',            '~> 4.2', '>= 4.2.7'
  spec.add_dependency 'haml',             '~> 4.0', '>= 4.0.7'
  spec.add_dependency 'haml-rails',       '~> 0.9.0'
  spec.add_dependency 'spin_to_win',      '~> 0.1.2'

  spec.add_development_dependency 'pg', '~> 0.18',  '>= 0.18.4'
  spec.add_development_dependency 'generator_spec', '~> 0'
  spec.add_development_dependency 'rspec-rails',    '~> 3.5', '>= 3.5.2'
end
