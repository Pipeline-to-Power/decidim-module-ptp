# Decidim::Sms-twilio

Twilio SMS integration.

## Usage

Sms-twilio will be available as a Component for a Participatory
Space. SMS-related tasks will be done with [Twilio sms gateway](https://www.twilio.com) after adding this module.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-ptp", github: "Pipeline-to-Power/decidim-module-ptp" do
  gem "decidim-sms-twilio"
end
```

And then execute:

```bash
bundle
```

## Configuration

You need to add the followings to your .rbenv-vars:

| Name                    | Description                                        | option   |
|    :---:                | :---                                               |   :---:  |
| TWILIO_ACCOUNT_SID      | Account SID from twilio.com                        | Required |
| TWILIO_AUTH_TOKEN       | Auth token from twilio.com/console                 | Require  |
| TWILIO_SENDER           | Sender number assigned to your account from Twilio | Required |


Please refer to [Twilio documentation](https://www.twilio.com/docs/twilio-cli) for more information.

Next, you need to add the followings to your secrets.yml file:

```yml
# Add the following to the end of your environment list:
twilio:
  twilio_account_sid: <%= ENV["TWILIO_ACCOUNT_SID"] %>
  twilio_auth_token: <%= ENV["TWILIO_AUTH_TOKEN"] %>
  twilio_sender: <%= ENV["TWILIO_SENDER"] %>
```

### Configure Omniauth from your system panel

Make sure you have enabled sms authentication option from system pannel.

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
