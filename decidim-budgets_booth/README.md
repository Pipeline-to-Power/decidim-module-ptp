# Decidim::Ptp-budgets

Improvements to the budgets module based on the customer requirements.

## Usage

This module is built on top of the decidim-budgets module and adds extra feature/capabilities including:
- Adding a booth on voting process so as to keep the user out of the unrelated parts during the voting. Users are still
  able to see different projects in a popup.
- Adding a confirmation notice before casting the actual vote.
- Adding a popup notice to let the user know he has successfully casted his/her vote.
- Some other alterations in decidim-budget views.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-ptp", github: "Pipeline-to-Power/decidim-module-ptp" do
  gem "decidim-budgets_booth"
end
```

And then execute:

```bash
bundle
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
