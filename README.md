# Decidim::Ptp

A [Decidim](https://github.com/decidim/decidim) module that encapsulates following capabilities:
1. [decidim-budgets_booth](decidim-budgets_booth/README.md) module, which overrides the voting process.
2. [decidim-l10n](decidim-l10n/README.md) module, that provides different formats for dates and times.
3. [decidim-sms-twilio](decidim-sms-twilio/README.md) module, which provides Twilio SMS integration.
4. [decdidim-smsauth](decdidim-smsauth/README.md) module, that provides SMS based authentication implementation.

You may add a selection of the these modules, in which case, please refer to those modules readme file.

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

Please refer to each of the sub-modules configurations.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## Testing

Each module has its own tests; please refer to each module for testing each module.

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
