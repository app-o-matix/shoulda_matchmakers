# Shoulda Matchmakers

[![Gem Version](https://badge.fury.io/rb/shoulda_matchmakers.svg)](https://badge.fury.io/rb/shoulda_matchmakers)

Shoulda Matchmakers facilitates the generation of Rspec tests for your existing ActiveRecord models and ActionController controllers using Thoughtbot's Shoulda Matchers https://github.com/thoughtbot/shoulda-matchers

Shoulda Matchmakers is based on Erwin Schens' Regressor https://github.com/ndea/regressor

## Supported Shoulda Matchers

#### ActiveRecord Models
ActiveRecord model Rspec tests can be generated for validations, associations, nested attributes, enum definitions, attribute serialization, database columns and database indexes using the following Shoulda Matchers:

- **ActiveModel Matchers**
    - allow_value
    - have_secure_password
    - validate_absence_of
    - validate_acceptance_of
    - validate_confirmation_of
    - validate_exclusion_of
    - validate_inclusion_of
    - validate_length_of
    - validate_numericality_of
    - validate_presence_of

- **ActiveRecord Matchers**
    - accept_nested_attributes_for
    - belong_to
    - define_enum_for
    - have_and_belong_to_many
    - have_db_column
    - have_db_index
    - have_many
    - have_one
    - have_readonly_attribute
    - serialize
    - validate_uniqueness_of

#### ActionController Controllers
ActionController controller Rspec tests can be generated for REST routes, before/after/around actions/filters, renders/responds/redirects/rescues, filter parameters, set session and set flash using the following Shoulda Matchers (*experimental):

- **ActionController Matchers**
    - filter_param
    - permit<sup>*</sup>
    - redirect_to<sup>*</sup>
    - render_template<sup>*</sup>
    - render_with_layout<sup>*</sup>
    - rescue_from
    - respond_with<sup>*</sup>
    - route
    - set_session<sup>*</sup>
    - set_flash<sup>*</sup>
    - use_after_action
    - use_around_action
    - use_before_filter

#### Other
Additional Rspec tests can be generated using the following independent Shoulda Matchers (*experimental):

- **Independent Matchers**
    - delegate_method<sup>*</sup>

### Factories
FactoryGirl factories containing the minimum attributes required for the factory to create a valid object can be generated for your ActiveRecord models.

## Get Shoulda Matchmakers

#### Rails
Add this line to your Gemfile:
```ruby
group :test do
  gem 'shoulda_matchmakers'
end
```

#### Directly from GitHub
```ruby
group :test do
  gem 'shoulda_matchmakers', git: 'https://github.com/app-o-matix/shoulda_matchmakers.git', branch: 'master'
end
```

## Install
```bash
bundle install
rails g shoulda_matchmakers:install
```

This will create the initializer file **shoulda_matchmakers.rb** in your application's `config/initializers` subdirectory. This initializer file provides configuration options that enable you to determine where generated tests will be saved, define subsets of models, controllers or factories to either be included in or excluded from test generation, and set your preference for test code maximum line length.

After you have installed Shoulda Matchmakers, add `require shoulda-matchers` and the following Shoulda Matchers configuration to your `spec/spec_helper.rb` file:
##### spec_helper.rb
```ruby
require 'shoulda-matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

## Usage

### Run the generators:
Be sure to run the generators in your **test environment** so that development-only gems, which could create conflicts, are not loaded.

#### ActiveRecord Models
You can generate Rspec tests for all of your applications's ActiveRecord models or selectively include or exclude models through command line options, configuration options in your Shoulda Matchmakers initialization file, or both.

- **Create Rspec tests for all of your applications's ActiveRecord models using Shoulda Matchers**. *(This assumes you have not specified any model includes or excludes in your Shoulda Matchmakers initialization file. Otherwise, any includes or excludes, but not both, will be applied. See your Shoulda Matchmakers initialization file for a description of include/exclude precedence.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:model_matcher
```

- **Create Rspec tests only for specified ActiveRecord models**. *(Any model includes or excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:model_matcher -i User Project::Issue Account
```

- **Create Rspec tests for specified ActiveRecord models as well as for any models included in your Shoulda Matchmakers initialization file**. *(Any model excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:model_matcher -I User Project::Issue Account
```

- **Create Rspec tests for all of your applications's ActiveRecord models except for the models specified**. *(Any model includes or excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:model_matcher -e User Project::Issue Account
```

- **Create Rspec tests for all of your applications's ActiveRecord models except for the models specified as well as for any models excluded in your Shoulda Matchmakers initialization file**. *(Any model includes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:model_matcher -E User Project::Issue Account
```

#### ActionController Controllers
You can generate Rspec tests for all of your applications's ActionController controllers or selectively include or exclude controllers through command line options, configuration options in your Shoulda Matchmakers initialization file, or both.

- **Create Rspec tests for all of your applications's ActionController controllers using Shoulda Matchers**. *(This assumes you have not specified any controller includes or excludes in your Shoulda Matchmakers initialization file. Otherwise, any includes or excludes, but not both, will be applied. See your Shoulda Matchmakers initialization file for a description of include/exclude precedence.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:controller_matcher
```

- **Create Rspec tests only for specified ActionController controllers**. *(Any controller includes or excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:controller_matcher -i UsersController Project::IssuesController
```

- **Create Rspec tests for specified ActionController controllers as well as any controllers included in your Shoulda Matchmakers initialization file**. *(Any controller excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:controller_matcher -I UsersController Project::IssuesController
```

- **Create Rspec tests for all of your applications's ActionController controllers except for the controllers specified**. *(Any controller includes or excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:controller_matcher -e UsersController Project::IssuesController
```

- **Create Rspec tests for all of your applications's ActionController controllers except for the controllers specified as well as for any controllers excluded in your Shoulda Matchmakers initialization file**. *(Any controller includes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:controller_matcher -E UsersController Project::IssuesController
```

#### Factories
You can generate FactoryGirl factories for all of your applications's ActiveRecord models or selectively include or exclude models either through command line options, configuration options in your Shoulda Matchmakers initialization file, or both.

- **Create FactoryGirl factories containing the minimum required attributes for all of your applications's ActiveRecord models**. *(This assumes you have not specified any factory includes or excludes in your Shoulda Matchmakers initialization file. Otherwise, any includes or excludes, but not both, will be applied. See your Shoulda Matchmakers initialization file for a description of include/exclude precedence.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:factory
```

- **Create FactoryGirl factories only for specified ActiveRecord models**. *(Any factory includes or excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:factory -i User Project::Issue Account
```

- **Create FactoryGirl factories for specified ActiveRecord models as well as for any factories included in your Shoulda Matchmakers initialization file**. *(Any factory excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:factory -I User Project::Issue Account
```

- **Create FactoryGirl factories for all of your applications's ActiveRecord models except for the models specified**. *(Any factory includes or excludes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:factory -e User Project::Issue Account
```

- **Create FactoryGirl factories for all of your applications's ActiveRecord models except for the models specified as well as for any factories excluded in your Shoulda Matchmakers initialization file**. *(Any factory includes specified in your Shoulda Matchmakers initialization file will be ignored.)*
```bash
RAILS_ENV=test rails generate shoulda_matchmakers:factory -E User Project::Issue Account
```

## Let's level set expectations
There are a couple of things to keep in mind when using this gem. First, Shoulda Matchmakers is not a turn-key solution, nor is it currently intended to be. While some of the Rspec tests generated will run without any additional code, many will require attribute values, additional befores, lets, etc., and/or code that accounts for relevant code in your application that exist within conditional statements, which at this time Shoulda Matchmakers is unable to discern. Second, the Shoulda Matchmakers gem is currently a prototype, so there will undoubtedly be bumps and hiccups early on. The good news is that Shoulda Matchmakers does not alter your application's code or functionality, so anything done can be undone. No harm, no foul!

## Why are some matchmakers marked as 'experimental'?
Well, 'experimental' seemed to induce a little more confidence than 'iffy' or 'crap shoot'. In truth, the 'experimental' signification is attached to matchmakers which rely on parsing your application's model or controller files in order to identify relevant code. And, at this stage, the parsing is still somewhat rudimentary which means it will likely have a higher level of success when your application utilizes more common, simplistic Ruby/Rails syntax for the code these parsings are attempting to identify. This dependency on more simplistic syntax makes these matchmakers a bit brittle, at times prone to overlook relevant code or, conversely, to mis-identify irrelevant code as relevant. This brittleness should continue to improve in subsequent versions through user feedback and parsing refinement, but it is important to be aware that, when using these matchmakers, you should verify the resulting generated tests for validity and accuracy. As stated above, though, Shoulda Matchmakers does not alter your application's code and, therefore, anything done can be undone.

## Compatibility
Shoulda Matchmakers was developed with Ruby 2.3.3, Rails 4.2.7, RSpec 3.5.2, Postgres 0.18.4, and Haml 4.0.7.

## Versioning
Shoulda Matchmakers follows Semantic Versioning 2.0 as defined at http://semver.org.

## License
Shoulda Matchmakers is copyright ©2016 App-o-matix Software. It is free software and may be redistributed under the terms specified in the MIT-LICENSE file.
