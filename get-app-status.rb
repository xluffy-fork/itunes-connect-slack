require 'Spaceship'
require 'json'

# Constants
itc_username = ENV["ITC_USERNAME"]
itc_password = ENV["ITC_PASSWORD"]

raise "missing itunes username or password" if (!itc_username || !itc_password)

Spaceship::Tunes.login(itc_username, itc_password)
apps = Spaceship::Tunes::Application.all
versions = apps.map do |app|
  editVersionInfo = app.edit_version
  liveVersionInfo = app.live_version

  version = {}

  if editVersionInfo
  	version[:editVersion] = {
  		name: app.name,
  		version: editVersionInfo.version,
  		status: editVersionInfo.app_status,
  		appId: app.apple_id,
  		iconUrl: app.app_icon_preview_url
  	}
  end

  if liveVersionInfo
  	version[:liveVersion] = {
  		name: app.name,
  		version: liveVersionInfo.version,
  		status: liveVersionInfo.app_status,
  		appId: app.apple_id,
  		iconUrl: app.app_icon_preview_url
  	}
  end

  version
end

puts JSON.dump versions
