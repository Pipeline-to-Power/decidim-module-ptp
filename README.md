# Decidim::Ptp

A [Decidim](https://github.com/decidim/decidim) module that encapsulates following capabilities:
1. decidim-budgets_booth module, which overrides the voting process.
2. decidim-l10n module, that provides different formats for dates and times.
3. decidim-sms-twilio module, which provides Twilio SMS integration.
4. decdidim-smsauth module, that provides SMS based authentication implementation.

You may add a selection of the these modules, in which case, please refer to those modules readme.

## Installation

Add the following to your application's Gemfile:

```ruby
gem "decidim-ptp", github: "Pipeline-to-Power/decidim-module-ptp", branch: "release/0.26-stable"
```
By the time of providing this documentation, this gem was not added to reby gem. If the gem has been added to the
rubygems, you can add it from the rubygem instead:

```ruby
gem "decidim-ptp"
```
And then execute:

```bash
bundle
```

## Configuration

### Configure Twilio

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

Aslo, add the sms option to your omniauth in your secrets, along with other omniauth options your organization may
provide:

```yml
  omniauth:
    sms:
      enabled: true
      icon: phone
```
Restart your server to make the changes available.

### Configure Omniauth from your system panel

Make sure you have enabled sms authentication from system pannel.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

### Testing

To run the tests run the following in the gem development path:

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

### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.


## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
