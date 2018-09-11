require("dotenv").config();
const poster = require("./post-update.js");
const dirty = require("dirty");
const db = dirty(process.env.DB_NAME || "kvstore.db");
const pollIntervalSeconds = process.env.POLL_INTERVAL_SECONDS || 120;

function checkAppStatus() {
  console.log("Fetching latest app status...");

  // invoke ruby script to grab latest app status
  var exec = require("child_process").exec;
  exec("ruby get-app-status.rb", function(err, stdout, stderr) {
    if (stderr) {
      return console.error(stderr);
    }
    if (err) {
      return console.error(error);
    }
    if (stdout) {
      // compare new app info with last one (from database)
      console.log(stdout);
      var versions = JSON.parse(stdout);

      versions.forEach(version => {
        // use the live version if edit version is unavailable
        var currentAppInfo = version["editVersion"]
          ? version["editVersion"]
          : version["liveVersion"];
        var lastAppInfo = db.get(`app-info-${currentAppInfo.appId}`);

        if (
          !lastAppInfo ||
          lastAppInfo.status != currentAppInfo.status
        ) {
          poster.slack(currentAppInfo, db.get(`submission-start-${currentAppInfo.appId}`));

          // store submission start time
          if (currentAppInfo.status == "Waiting For Review") {
            db.set(`submission-start-${currentAppInfo.appId}`, new Date());
          }
        } else if (currentAppInfo) {
          console.log(
            `Current status "${
              currentAppInfo.status
            }" of "${currentAppInfo.name}" matches previous status`
          );
        } else {
          console.log(`Could not fetch status of "${currentAppInfo.name}"`);
        }

        // store latest app info in database
        db.set(`app-info-${currentAppInfo.appId}`, currentAppInfo);
      });
    } else {
      console.error(`There was a problem fetching the status of "${currentAppInfo.name}"!`);
    }
  });
}

setInterval(checkAppStatus, pollIntervalSeconds * 1000);
checkAppStatus();
