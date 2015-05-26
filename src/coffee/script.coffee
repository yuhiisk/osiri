$ = require './jquery.js'
Events = require('events').EventEmitter

do (win = window, doc = window.document) ->

    'use strict'

    ###
    # Model
    ###
    class SpeechSynth extends Events

        constructor: ->
            super()
            @data =
                blob: null

            @apiKey = '6c612e594d5a32557748352e6b496a6a5031492f6631634c4f6d6d682e7674375635552f6e48304b667a37'
            @url = 'https://api.apigw.smt.docomo.ne.jp/virtualNarrator/v1/textToSpeech?APIKEY=' + @apiKey

            @initialize()

        initialize: ->

        synth: (text, sex) ->
            # console.log sex
            self = @
            postData =
                Command: "AP_Synth"
                TextData: text
                SpeakerID: sex
                SpeechRate: '1.00'
                PowerRate: '1.00'
                VoiceType: '0'
                AudioFileFormat: '0'


            xhr = new XMLHttpRequest()
            xhr.open('POST', @url, true)

            #------- [1] -------
            xhr.responseType = 'arraybuffer'

            xhr.setRequestHeader("Content-Type", "application/json; charset=utf-8")

            xhr.onload = ->
                if @readyState == 4 and this.status == 200
                    #------- [2] -------
                    view = new Uint8Array(@response)

                    #------- [3] -------
                    blob = new Blob([view], { "type" : "audio/wav" })
                    self.data.blob = blob
                    self.emit('synth', blob)

                    #------- [4] -------

            xhr.send(JSON.stringify(postData))


    class AppModel extends Events

        constructor: (profile) ->
            super()
            @data =
                context: ''
            @profile = profile

            @apiKey = '6c612e594d5a32557748352e6b496a6a5031492f6631634c4f6d6d682e7674375635552f6e48304b667a37'
            @url = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=' + @apiKey

            @initialize()

        initialize: ->

            @synth = new SpeechSynth()
            @synth.on('synth', (blob) =>
                @emit('ready', blob)
            )

            @voice = new AudioPlayer()
            @voice.on('ended', (e) =>
                @emit('finished', e, @data.utt)
            )

        fetch: (text) ->
            postData = _.extend(@profile, { utt: text, context: @data.context })

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

        think: (text) ->
            console.log @profile.sex
            if @profile.sex is "女"
                sex = '0'
            else if @profile.sex is "男"
                sex = '1'

            @synth.synth(@data.utt, sex)

        say: (blob) ->
            @voice.set(blob).play()



    class AudioPlayer extends Events

        constructor: ->

            @initialize()

        initialize: ->

            @audio = new Audio()
            @audio.addEventListener('ended', (e) =>
                @emit('ended', e)
            , false)

        getAudio: ->
            return @audio

        set: (blob) ->
            URL = window.URL || window.webkitURL
            @audio.src = URL.createObjectURL(blob)
            @

        play: ->
            @audio.play()
            @


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

    male = new AppModel(
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
        t: '30'
    )
    female = new AppModel(
        nickname: 'いそっぷ'
        nickname_y: 'イソップ'
        sex: '女'
        bloodtype: 'A'
        birthdateY: '1985'
        birthdateM: '3'
        birthdateD: '19'
        age: '30'
        constellations: '牡羊座'
        place: '東京'
        mode: 'dialog'
        t: ''
    )

    inputView.on('submit', (e) ->
        chatView.add(e)
        male.fetch(e)
    )

    # 会話を取得後
    male.on('fetch', (data) ->
        console.log 'male fetch'
        male.think(data.utt)
    )
    female.on('fetch', (data) ->
        console.log 'female fetch'
        female.think(data.utt)
    )

    # 会話開始
    male.on('ready', (blob) ->
        male.say(blob)
        chatView.add(male.data.utt)
    )
    female.on('ready', (blob) ->
        female.say(blob)
        chatView.add(female.data.utt)
    )

    # 話し終わった
    male.on('finished', (e, utt) ->
        female.fetch(utt)
    )
    female.on('finished', (e, utt) ->
        male.fetch(utt)
    )


