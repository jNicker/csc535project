###
window.client = new Faye.Client('/faye')

client.addExtension {
  outgoing: (message, callback) ->
    message.ext = message.ext || {}
    message.ext.csrfToken = $('meta[name=csrf-token]').attr('content')
    callback(message)
}

jQuery ->
  $('#new_chat').submit ->
    $(this).find("input[type='submit']").val('Sending...').prop('disabled', true)

  try
    clinet.unsubscribe '/global'
  catch
    console?.log "Can't Unsubscribe"

  client.subscribe '/global', (payload) ->
    $('#global_chat').prepend(payload.message) if payload.message
###
