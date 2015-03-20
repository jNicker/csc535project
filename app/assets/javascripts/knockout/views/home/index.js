$(function() {
  window.client = new Faye.Client('/faye');

  client.addExtension({
    outgoing: function(message, callback) {
      message.ext = message.ext || {};
      message.ext.csrfToken = $('meta[name=csrf-token]').attr('content');
      return callback(message);
    }
  });

  function VModel() {
    var self = this;

    self.now = ko.observable(new Date());

    self.messages = ko.observableArray();

    //online_users
    self.online_users = ko.observableArray();

    self.findUser = function(id) {
      return _.find(self.online_users(), function(online_user) {
        return online_user.id() === id;
      })
    }

    //for when receiving notification of availabiltiy change
    self.updateOnlineUserAvailability = function(id, is_available) {
      self.findUser(id).is_available(is_available);
    }

    //for adding users on first load and when they sign in
    self.addUser = function(user_params) {
      self.online_users.push(new User(user_params));
    }

    //for removing users when they sign out
    self.deleteUser = function(id) {
      self.online_users.remove(function(online_user) {
        return online_user.id() === id;
      });
    }

    //current_user
    self.current_user = ko.observable();

    //for notifying current user availabilty has changed
    self.updateCurrentUserAvailablity = function(is_available) {
      current_user.is_available(is_available);
      if(is_available) {
        client.publish('/available', ko.toJS(self.current_user));
      } else {
        client.publish('/unavailable', ko.toJS(self.current_user));
      }
    }

    //to_user
    self.to_user_id = ko.observable();
    self.to_user_name = ko.computed(function() {
      if (self.to_user_id() !== undefined) {
        return self.findUser(self.to_user_id()).username();
      }
    })

    //for notifying to_user availability has changed
    self.updateToUserAvailabiltiy = function(is_available) {
      var to_user = self.findUser(self.to_user_id());
      self.updateOnlineUserAvailability(to_user.id(), is_available);
      if(is_available) {
        client.publish('/available', ko.toJS(self.to_user_id));
      } else {
        client.publish('/unavailable', ko.toJS(self.to_user_id));
      }
    }

    self.receiveStartChatRequest = function(start_chat_request) {
      if (self.current_user().is_available()) {
        if (start_chat_request.from_user.id === self.current_user().id()) {
          self.messages([]);
          self.current_user.is_available(false); //direct access because dont want to notify again
          self.to_user_id(start_chat_request.to_user.id);
        }
      }
    }

    self.sendStartChatReqeust = function(to_user) {
      if (self.current_user().is_available()) {
        if (to_user.is_available()) {
          client.publish('/startchat', {
            to_user: ko.toJS(self.current_user),
            from_user: ko.toJS(to_user)
          });
          self.to_user_id(to_user.id())
          self.updateCurrentUserAvailablity(false);
          self.updateToUserAvailabiltiy(false);
        }
      }
    }

    self.receiveStopChatRequest = function(stop_chat_request) {
      if (!self.current_user().is_available()) {
        if (stop_chat_request.to_user.id === self.to_user_id()) {
          if (stop_chat_request.from_user.id == self.current_user().id()) {
            self.current_user().is_available(true);
            self.to_user_id(undefined);
          }
        }
      }

    }

    self.sendStopChatRequest = function(to_user) {
      client.publish('/stopchat', {
        to_user: ko.toJS(self.current_user),
        from_user: ko.toJS(to_user)
      });
      self.updateToUserAvailabiltiy(true);
      self.updateCurrentUserAvailablity(true);
      self.to_user_id(undefined);
    }

    self.sendMessage = function() {

    }

    self.receiveMessage = function() {

    }

  }

  ViewModel = new VModel();

  //add all the online users
  _.each(online_users, function(online_user) {
    ViewModel.online_users.push(new User(online_user));
  });

  ViewModel.current_user(new User(this_user));

  // connections

  // signon
  client.subscribe('/online', function(payload) {
    ViewModel.updateOrAddUser(user);
  });
  client.publish('/online', ko.toJS(ViewModel.current_user));

  // signout
  client.subscribe('/offline', function(payload) {
    ViewModel.deleteUser(user);
  });

  $(window).unload(function() { // this hits the rails home#destroy and that sends the faye message
    $.ajax({
      url: '/home/' + ViewModel.current_user().id(),
      type: "DELETE",
      async: false,
    });
  });

  // chat requests
  client.subscribe('/startchat', function(payload) {
    ViewModel.receiveStartChatRequest(payload);
  });

  client.subscribe('/stopchat', function(payload) {
    if (!ViewModel.current_user().is_available() && payload.to_user.id === ViewModel.current_user().id()) {
      ViewModel.stopRemoteChat(end_chat_request);
    }
  });

  // availability    nobody can change your availability without a chat request
  client.subscribe('/available', function(payload) {
    if (payload.id !== ViewModel.current_user().id()) {
      ViewModel.updateOnlineUserAvailability(payload.id, true);
    }
  });

  client.subscribe('/unavailable', function(payload) {
    if (payload.id !== ViewModel.current_user().id()) {
      ViewModel.updateOnlineUserAvailability(payload.id, false);
    }
  });

  ko.applyBindings(ViewModel);

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
