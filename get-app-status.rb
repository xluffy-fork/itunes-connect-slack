require 'Spaceship'
require 'json'

# Constants
itc_username = ENV['ITC_USERNAME']
itc_password = ENV['ITC_PASSWORD']

raise 'missing itunes username or password' if !itc_username || !itc_password

Spaceship::Tunes.login(itc_username, itc_password)
apps = Spaceship::Tunes::Application.all
versions = apps.map do |app|
  edit_version_info = app.edit_version
  live_version_info = app.live_version

  version = {}

  if edit_version_info
    version[:edit_version] = {
      name: app.name,
      version: edit_version_info.version,
      status: edit_version_info.app_status,
      appId: app.apple_id,
      iconUrl: app.app_icon_preview_url
    }
  end

  if live_version_info
    version[:live_version] = {
      name: app.name,
      version: live_version_info.version,
      status: live_version_info.app_status,
      appId: app.apple_id,
      iconUrl: app.app_icon_preview_url
    }
  end

  version
end

puts JSON.dump versions
