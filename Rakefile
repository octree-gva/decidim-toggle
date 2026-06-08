# frozen_string_literal: true

require "decidim/dev/common_rake"

def install_deps(path)
  Dir.chdir(path) do
    system("bundle exec rails decidim:update")
    system("bundle exec rake db:migrate")
  end
end

def seed_db(path)
  Dir.chdir(path) do
    system("bundle exec rake db:seed")
  end
end

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task :development_app do
  Bundler.with_original_env do
    generate_decidim_app(
      "development_app",
      "--app_name",
      "#{base_app_name}_development_app",
      "--path",
      "..",
      "--recreate_db",
      "--demo",
      "--locales",
      "en,ca,es,fr"
    )
  end
  install_deps("development_app")
  seed_db("development_app")
end
