{View} = require 'atom'

module.exports =
class MsgView extends View
  @content: (message) ->
    @li class: 'file entry list-item', =>
      @span "#{message.username}#{message.uuid}: #{message.text}", class: 'msg', outlet: 'msgText'

  initialize: () ->
