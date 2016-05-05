
Parse.Cloud.job("check", function (request, status) {
  var promises = [];
  var notificationClass = Parse.Object.extend("Notifications");
  var notificationQuery = new Parse.Query(notificationClass);
  notificationQuery.equalTo("Sent", false);
  notificationQuery.limit = 1000;
  notificationQuery.find().then(function(qresults) {
    if ((qresults.length) > 0) {
      limiting(qresults, 0)
      console.log("first")
      console.log(qresults.length)
      console.log("second")
    }
  function limiting(qresults, i) {
      var notification = qresults[i];
      var legacy = notification.get('Legacy');
      var arcs = notification.get('Arcs');
      var message = notification.get('Message');
      var fromUser = notification.get('fromUser');
      var toUser = notification.get('toUser');
      var awardee = notification.get('Awardee');
      var awarder = notification.get('Awarder');
      var notify = notification.get('Notify');
      notification.set('Sent', true);
      notification.save().then(function() {



      var emoji = "⭐️"
      var legacyClass = Parse.Object.extend("Legacies");
      var legacyQuery = new Parse.Query(legacyClass);
      legacyQuery.equalTo("Name", legacy);
      legacyQuery.find().then(function(results) {
        var theLegacy = results[0];
        emoji = theLegacy.get("Emoji")
        if (notify == -1) {
          theLegacy.increment("Gratitudes", 1);
        }
        theLegacy.increment("TotalArcs", arcs);
        theLegacy.save().then(function() {

          var installationQuery = new Parse.Query(Parse.Installation);
          var note = (String(emoji) + " " + String(arcs.toFixed(0)) + " Arcs to " + String(legacy) + "'s " + String(awardee) + ": " + String(message) + " -" + String(awarder))
          if (notify == 0) {
            installationQuery.equalTo("user", toUser)

          };
          if (notify == -1) {
            installationQuery.equalTo("user", toUser)
            note = ("Gratitude from " + String(awarder) + ": " + String(message))
          };
          if (notify == 1) {
            installationQuery.equalTo("legacy", legacy)
          };
          //installationQuery.equalTo("Legac")
          promises.push(Parse.Push.send({
            where: installationQuery,
            data: {
              alert: note,
              badge: "Increment"
            }
          }));
          //my own loop to force synchonus
          i = i + 1
          console.log(i)
          console.log(qresults.length)
          if (i < (qresults.length)) {
            limiting(qresults, i)
            console.log("again")
          }
      });
    });

  });
}
});
    Parse.Promise.when(promises).then(function() {
      //  status.success("Promises yay!")
    })
});
Parse.Cloud.job("gratitudes", function (request, status) {
  // Parse.User.allowCustomUserClass(true);
//  var userClass = Parse.Object.extend("User");
Parse.Cloud.useMasterKey();
  var userQuery = new Parse.Query(Parse.User);
  userQuery.notEqualTo("DailyGratitude", false);
//  userQuery.include('DailyGratitude');

  userQuery.find({useMasterKey: true}).then(function(users) {
  //  newUsers = [];
    for (var m = 0; m < (users.length); m++) {
      if ((users.length) > 0) {
        wait(users, 0);
      };
    };
  });
    //  newUsers.push(user);
    function wait (users, n) {
      user = users[n]
      console.log(user);
      user.set('DailyGratitude', false);
      user.save({useMasterKey: true}).then(function() {
        wait(users, (n + 1));
      });
    };

  //  return newUsers;

  // }).then(function(newUsers) {
  //   console.log(newUsers);
  //   Parse.Object.saveAll(newUsers);
  // });
});

Parse.Cloud.job("reminder", function (request,status) {
  var promises = [];

  var userQuery = new Parse.Query(Parse.User);
  userQuery.equalTo("DailyGratitude", false);
  userQuery.containedIn("Role", ["E", "F"])
  var text = "Feeling Thankful? Don't forget to send your daily gratitude!"

  userQuery.find({useMasterKey: true}).then(function(falseUsers) {
    var installations = new Parse.Query(Parse.Installation);
    installations.containedIn("user", falseUsers)
    // for (var r = 0; r < (falseUsers.length); r++) {
    //   var user = falseUsers[r]
    //   console.log(user);
    // }
    return installations
  }).then(function(installations){
    promises.push(Parse.Push.send({
      where: installations,
      data: {
        alert: text,
        badge: "Increment"
      }
    }));
  });
  Parse.Promise.when(promises).then(function() {
    //  status.success("Promises yay!")
  })
});
