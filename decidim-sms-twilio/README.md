# Decidim::Sms-twilio

Twilio SMS integration.

## Usage

Sms-twilio will be available as a Component for a Participatory
Space.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-ptp", github: "Pipeline-to-Power/decidim-module-ptp", branch: "release/0.26-stable" do
  gem "decidim-sms-twilio"
end
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

## License

See [LICENSE-AGPLv3.txt](../LICENSE-AGPLv3.txt).
