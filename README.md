# Decidim::Ptp

A [Decidim](https://github.com/decidim/decidim) module that encapsulates following capabilities:
1. Decidim::BudgetsBooth module, which overrides the voting process.
2. Decidim::L10n module, that provides different formats for dates and times.
3. Decidim::Sms::Twilio, which provides Twilio SMS integration.
4. Decidim::Smsauth, that provides SMS based authentication implementation.

You may add a selection of the these modules, in which case, please refer to those modules readme.
The development has been sponsored by the
[Add the sponsor](http://www.add_sponsore.me)

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
default: &default
# Add the following to the end of your default list:
twilio:
  twilio_account_sid: <%= ENV["TWILIO_ACCOUNT_SID"] %>
  twilio_auth_token: <%= ENV["TWILIO_AUTH_TOKEN"] %>
  twilio_sender: <%= ENV["TWILIO_SENDER"] %>
```

Aslo, add the sms option to your omniauth in your secrets, along with other omniauth options your organization may
provide:

```yml
default:
  <<: *default
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

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
