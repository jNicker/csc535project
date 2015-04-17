$(function() {
  // Setup Faye Client
  window.client = new Faye.Client('/faye', {retry: 15});
  client.addExtension({
    outgoing: function(message, callback) {
      message.ext = message.ext || {};
      message.ext.csrfToken = $('meta[name=csrf-token]').attr('content');
      return callback(message);
    }
  });

  // Define ViewModel
  function VModel() {
    var self = this;
    self.now = ko.observable(new Date()); // date for message sent time
    self.messages = ko.observableArray(); // array of messages received
    self.current_user = ko.observable();  // current user
    self.to_user_id = ko.observable(0);    // who are we chatting with
    self.online_users = ko.observableArray(); // users

    self.to_user_name = ko.computed(function() {  // who are we chatting with for display
      if (self.to_user_id() !== 0) {
        return self.findUser(self.to_user_id()).username();
      }
    });

    self.findUser = function(id) { // find a user by id, or return undefined
      return _.find(self.online_users(), function(online_user) {
        return online_user.id() === id;
      })
    }

    self.addOrCreateUser = function(user) {
      new_user = self.findUser(user.id)
      if (new_user == undefined) {
        self.addUser(user);
      }
    }

    self.changeUserAvailability = function(user_id, available) { // find and change user availablity
      var user = self.findUser(user_id);
      if (user !== undefined) {
        user.is_available(available);
      }
    }

    self.changeUserOnline = function(user_id, online) {
      var user = self.findUser(user_id);
      if (user !== undefined) {
        if (!online) {
          user.is_available(false);
        }
        user.is_online(online);
      }
    }

    self.addUser = function(user_params) {
      self.online_users.push(new User(user_params));
    }

    //for removing users when they sign out
    self.deleteUser = function(user) {
      self.online_users.remove(function(online_user) {
        return online_user.id() === user.id;
      });
    }

    self.stopChat = function(broadcast) {
      if (broadcast) {
        console.log("Publish /stopchat : ");
        console.log([self.to_user_id(), self.current_user().id()]);
        client.publish('/stopchat', [self.to_user_id(), self.current_user().id()], {attempts: 1})
      }
      self.to_user_id(0);
      self.messages([]);
    }

    self.clickedStartChat = function(user) {
      self.to_user_id(user.id());
      console.log("Publish /startchat : ");
      console.log([user.id(), self.current_user().id()]);
      ViewModel.changeUserAvailability(self.to_user_id(), false);
      client.publish('/startchat', [user.id(), self.current_user().id()], {attempts: 1});
    }

    self.clickedStopChat = function() {
      self.changeUserAvailability(self.to_user_id(), true);
      self.stopChat(true);

    }

    self.sendMessage = function() {

    }

    self.receiveMessage = function() {

    }

  }
  ViewModel = new VModel();

  // add all the online users
  _.each(online_users, function(online_user) {
    ViewModel.online_users.push(new User(online_user));
  });
  // set current user
  ViewModel.current_user(new User(this_user));


  // EVENTS //
  // CONNECTION //
  // signon
  client.subscribe('/signon', function(user) {
    console.log("Subscribe /signon : ");
    console.log(user);
    ViewModel.addOrCreateUser(user);
    ViewModel.changeUserAvailability(user.id, true);
    ViewModel.changeUserOnline(user.id, true);
  });
  client.publish('/signon', ko.toJS(ViewModel.current_user));
  // signout
  client.subscribe('/signoff', function(user) {
    console.log("Subscribe /signoff : ");
    console.log(user);
    ViewModel.addOrCreateUser(user);
    ViewModel.changeUserAvailability(user.id, false);
    ViewModel.changeUserOnline(user.id, false);
    // if (user.id === ViewModel.to_user_id()) {
    //   ViewModel.stopChat(false);
    // }
  });
  $(window).unload(function() { // this hits the rails home#destroy and that sends the faye message
    $.ajax({
      url: '/home/' + ViewModel.current_user().id(),
      type: "DELETE",
      async: false,
      data: { chatting_with: ViewModel.to_user_id() }
    });
  });

  // CHAT REQUESTS //
  // startchat
  client.subscribe('/startchat', function(user_ids) {
    console.log("Subscribe /startchat : ");
    console.log(user_ids);
    //if user_ids contains current user id
    if( _.contains(user_ids, ViewModel.current_user().id())) {
      other_user_id = _.without(user_ids, ViewModel.current_user().id())[0];
      if(ViewModel.to_user_id() != other_user_id) {
        ViewModel.to_user_id(other_user_id);
        ViewModel.changeUserAvailability(other_user_id, false);
      }
    }
    else { //otherwise
      _.each(user_ids, function(user_id) {
        ViewModel.changeUserAvailability(user_id, false);
      });
    }
  });

  // endchat
  client.subscribe('/stopchat', function(user_ids) {
    console.log("Subscribe /stopchat : ");
    console.log(user_ids);
    //if user_ids contains current user id
    if( _.contains(user_ids, ViewModel.current_user().id())) {
      other_user_id = _.without(user_ids, ViewModel.current_user().id())[0];
      if(ViewModel.to_user_id() == other_user_id) {
        ViewModel.stopChat(false);
        ViewModel.changeUserAvailability(other_user_id, true);
    }
    }
    else { //otherwise
      _.each(user_ids, function(user_id) {
        ViewModel.changeUserAvailability(user_id, true);
      });
    }
  });

  // MESSAGES //
  // subscribe to self
  client.subscribe('/' + this_user.username, function(message) {
    console.log("Subscribe /" + this_user.username + " : ");
    console.log(message);
    ViewModel.messages.unshift(new Message(message));
    ViewModel.now(new Date());
  });

  ko.applyBindings(ViewModel);

  setInterval(function() {
    ViewModel.now(new Date());
    console.log("New Now")
  }, 50 * 1000);

});


// publisher = client.publish('/chats/global', {
//   message: '<%= j render @message %>'
// });

// publisher.callback(function() {
//   $('#message_body').val('');
//   $('#new_message').find("input[type='submit']").val('Send').prop('disabled', false);
// });

// publisher.errback(function() {
//   alert('There was and error sending your message.');
// })
