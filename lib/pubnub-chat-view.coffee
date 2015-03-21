{allowUnsafeEval} = require 'loophole'
{$, ScrollView, View, EditorView} = require 'atom'
{$$} = allowUnsafeEval -> require 'jquery'
_ = allowUnsafeEval -> require 'underscore-plus'
MsgView = require './pubnub-msg-view'
PUBNUB = allowUnsafeEval -> require('pubnub').init({
                                                    publish_key:atom.config.get('pubnub-chat.publish_key'),
                                                    subscribe_key:atom.config.get('pubnub-chat.subscribe_key'),
                                                    });

module.exports =
  class PubnubChatView extends ScrollView

    @content: ->
      @div class: 'pubnub-wrapper', =>
        @div class: 'pubnub-header list-inline tab-bar inset-panel', =>
          @div "Channel: #{atom.config.get('pubnub-chat.channel')}", class: 'pubnub-title', outlet: 'title'
        @div class: 'pubnub-chat', =>
          @div class: 'select-list', =>
            @subview 'filterEditorView', new EditorView(mini: true)
          @button 'Send', class:'btn my_btn', outlet: 'send_button'
          @div class: 'pubnub-chat-scroller', outlet: 'scroller', =>
            @ul class: 'msglist', tabindex: -1, outlet: 'list'

    initialize: () ->
      self = @
      @width(400)
      @initChannel()

      # ctrl+o can be used for commeand.
      atom.workspaceView.command "pubnub-chat:open-conversation", =>
        console.log "testing ctrl+o"
    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    ############################################################
    # Main Methods
    #
    ############################################################
    initChannel: ->
      self = @
      self.channel = atom.config.get('pubnub-chat.channel')
      self.uuid = Math.floor(Math.random() * 1000)
      self.username = atom.config.get('pubnub-chat.username')
      self.myhistory = []

      PUBNUB.subscribe
        channel: self.channel
        callback: (message) ->
          addMsg(message)

      PUBNUB.history
        channel  : self.channel
        limit    : 100
        callback : (history) ->
          hist1 = history[0]
          for msg in hist1
            addMsg(msg)

      @filterEditorView.setText('type here')

      @filterEditorView.on 'keyup', (event) ->
        key = event.keyCode || event.which
        if key == 13
          sendmsg()
        else

      @send_button.on 'click', ->
        sendmsg()
        self.filterEditorView.focus()

      sendmsg = ->
        message = {
              text: ''
              uuid: ''
              username: ''
            }
        message['text'] = self.filterEditorView.getText()
        message['uuid'] = self.uuid
        message['username'] = self.username
        PUBNUB.publish
          channel: self.channel
          message: message
          callback: ->
        self.filterEditorView.setText('')
        message['text'] = ''
        message['uuid'] = ''
        message['username'] = ''

      addMsg = (message) ->
        self.list.prepend new MsgView(message)

    ############################################################
    # Display and Focus
    #
    ############################################################
    toggle: ->
      if @isVisible()
        @detach()
      else
        @show()

    show: ->
      @attach() unless @hasParent()
      @focus()

    attach: ->
      if atom.config.get('pubnub-chat.show_on_right_side')
        @removeClass('panel-left')
        @addClass('panel-right')
        atom.workspaceView.appendToRight(this)
      else
        @removeClass('panel-right')
        @addClass('panel-left')
        atom.workspaceView.appendToLeft(this)

    detach: ->
      super
      atom.workspaceView.focus()