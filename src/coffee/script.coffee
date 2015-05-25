$ = require './jquery.js'

do (win = window, doc = window.document) ->

    'use strict'

    class AppModel

        constructor: ->

            @apiKey = '6c612e594d5a32557748352e6b496a6a5031492f6631634c4f6d6d682e7674375635552f6e48304b667a37'
            @url = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=' + @apiKey

            @initialize()

        initialize: (@name = 'Hello World!') ->
            @fetch('こんにちは')

        fetch: (text) ->
            $.ajax(
                type: 'POST'
                url: @url
                dataType: 'json'
                data:
                    utt: text
            )

    model = new AppModel()
