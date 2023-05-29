# frozen_string_literal: true

require "decidim/dev/common_rake"

def seed_db(path)
  Dir.chdir(path) do
    system("bundle exec rake db:seed")
  end
end

def install_modules(path)
  Dir.chdir(path) do
    system("bundle exec rake decidim_sms_twilio:install:migrations")
    system("bundle exec rake decidim_smsauth:install:migrations")
    system("bundle exec rake db:migrate")
  end
end

# Temporary fix to overcome the issue with babel plugin updates, see:
# https://github.com/decidim/decidim/pull/10916
def fix_babel_config(path)
  Dir.chdir(path) do
    babel_config = "#{Dir.pwd}/babel.config.json"
    File.delete(babel_config) if File.exist?(babel_config)
    FileUtils.cp("#{__dir__}/babel.config.json", Dir.pwd)
  end
end

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  ENV["RAILS_ENV"] = "test"
  fix_babel_config("spec/decidim_dummy_app")
  install_modules("spec/decidim_dummy_app")
end

desc "Generates a development app"
task :development_app do
  Bundler.with_original_env do
    generate_decidim_app(
      "development_app",
      "--app_name",
      "#{base_app_name}_development_app",
      "--path",
      "..",
      "--recreate_db",
      "--demo"
    )
  end

  fix_babel_config("development_app")
  install_modules("development_app")
  seed_db("development_app")
end
