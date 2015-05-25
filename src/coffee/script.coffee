$ = require './jquery.js'
Events = require('events').EventEmitter

do (win = window, doc = window.document) ->

    'use strict'

    ###
    # Model
    ###
    class AppModel extends Events

        constructor: ->
            super()
            @data =
                context: ''

            @apiKey = '6c612e594d5a32557748352e6b496a6a5031492f6631634c4f6d6d682e7674375635552f6e48304b667a37'
            @url = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=' + @apiKey

            @initialize()

        initialize: ->

        fetch: (text) ->
            postData =
                utt: text
                context: @data.context
                nickname: 'いそっぷ'
                nickname_y: 'イソップ'
                sex: '男'
                bloodtype: 'A'
                birthdateY: '1985'
                birthdateM: '4'
                birthdateD: '1'
                age: '30'
                constellations: '牡羊座'
                place: '横浜'
                mode: 'dialog'
                t: ''

            $.ajax(
                type: 'post'
                url: @url
                contentType: 'application/json; charset=utf-8'
                dataType: 'json'
                data: JSON.stringify(postData)
            ).done((data) =>
                @data = data
                @emit('fetch', data)
            )

    ###
    # View
    ###
    class ChatView extends Events

        constructor: (id = 'Chat') ->

            @el = doc.getElementById(id)
            @initialize()

        initialize: ->

        add: (text) ->
            p = doc.createElement('p')
            textNode = doc.createTextNode(text)
            p.appendChild(textNode)
            @el.appendChild(p)


    class InputView extends Events

        constructor: (id = 'Control') ->

            @el = doc.getElementById(id)
            @input = @el.querySelector('.control__input')
            @submit = @el.querySelector('.control__submit')

            @initialize()
            @eventify()

        initialize: ->

            @input.value = ''

        eventify: ->

            # @input.addEventListener('keyup', (e) =>
                # if e.which is 13
                    # @emit('submit', @input.value)
                    # @input.value = ''
            # , false)

            @submit.addEventListener('click', (e) =>
                @emit('submit', @input.value)
                @input.value = ''
            , false)

    ###
    # Entry Point
    ###
    chatView = new ChatView()
    inputView = new InputView()
    model = new AppModel()

    inputView.on('submit', (e) ->
        chatView.add(e)
        model.fetch(e)
    )
    model.on('fetch', (data) ->
        chatView.add(data.utt)
        inputView.input.focus()
    )
    model.fetch()

