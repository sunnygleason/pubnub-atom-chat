PubnubChatView = require './pubnub-chat-view'

{allowUnsafeEval} = require 'loophole'
$ = allowUnsafeEval -> require 'jquery'
_ = allowUnsafeEval -> require 'underscore-plus'


module.exports =
  configDefaults:
    username: 'Anonymous'
    channel: 'GenChat'
    subscribe_key: 'demo'
    publish_key: 'demo'
    show_on_right_side: true
  pubnubChatView: null

  activate: (state) ->
    @pubnubChatView = new PubnubChatView()
    atom.workspaceView.command "pubnub-chat:toggle", =>
      @pubnubChatView.toggle()

  deactivate: ->
    @pubnubChatView.destroy()

  serialize: ->
    pubnubChatViewState: @pubnubChatView.serialize()