# Decidim::BudgetsBooth

This module aims at wrapping up the voting process so as to help users focus voting once they enter the booth, and keeps away other irrelevant information. Also, the module introduces "zip code" workflow, in which users are limited to vote the budgets from the same neighborhood/borough. click [here](docs/ZIP_CODE_VOTING.md) for more information about how to set the zip codes.

## Usage

This module is built on top of the decidim-budgets module and adds extra feature/capabilities.
After installing and configuring this module, you should be able to select the "zip code" workflow from your budgets' component configuration as shown as follows:
![zip code workflow](zip-code-workflow.png)
This module adds the following feature to the [main branch](https://github.com/pipeline-to-Power/decidim-module-ptp/):

- Adding capability of adding/editing zip code for the user (users may change their zip code only if they have not voted yet, or if they have deleted all of their votes).
- Capability of enabling/disabling "zip code" workflow from components configuration.
- Defining cancel and after finishing voting redirects (useful for asking for feedback, for example, after completing voting).
- Introducing maximum number of budgets, in which users can vote.
- Adding after voting and after completing voting message, configurable from admin panel.
- Capability of showing/hiding vote instruction, when the user starts to vote.
- Capability of showing image in after voting popup.
- Reverting the confirmation page to the popup.
- Capability of Adding image to the budgets from back office.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-ptp", github: "Pipeline-to-Power/decidim-module-ptp", branch: "feature/0.26/zip-code-voting" do
  gem "decidim-budgets_booth"
end
```

And then execute:

```bash
bundle
```

## Configuration

### Admin configuration

To configure this module correctly, you need to first define and set the zip codes correctly ([click here for more information](docs/ZIP_CODE_VOTING.md)). Next, you can configure the following options from your budgets configurations:

- Vote based on ZIP code: allows participants to vote on budgets matching their entered ZIP code: Selecting this option enables zip code workflow.
- Maximum number of budgets that user can vote on: this options limits the number of budgets a user can vote on. the default for this value is zero, which means that users can vote in all budgets, made available through selected workflows.
- Popup text after each vote: The content of the popup which is being shown after each voting.
- Popup text after voting in all available budgets: he content of the popup which is being shown after user voted in all available budgets.
- Terms and conditions to be shown when user wants to enter their ZIP code: Set of terms and conditions you ask the users to admit before adding/editing their zip code (this message is being set in zip code entering view).
- URL to redirect user after voting on all available budgets (default is budgets list)
- URL to redirect user when canceling voting (default to the root path)
- Show full project descriptions on the listing page and disable the details popup: By selecting this button, once the users enter the voting booth, they see the complete project information (not truncated version).

### Hard coded configuration

You can set the number of digits for the zip codes. The default is set to 5, which is the case for most of the countries. But if you need to add/remove the digits, you can set it from the "zip_code_length".
To do so, you need to add an initializer, and add the following:
```ruby
Decidim::BudgetsBooth.configure do |config|
# change this value to desired value
  config.zip_code_length = 5
end
```

## Testing

To run the tests, run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

## Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.
