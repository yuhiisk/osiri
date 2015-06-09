$ = require './jquery.js'
Events = require('events').EventEmitter

do (win = window, doc = window.document) ->

    'use strict'

    CONTEXT = ''

    ###
    # Model
    ###
    class SpeechSynth extends Events

        constructor: ->
            super()
            @data =
                blob: null

            @apiKey = '6c612e594d5a32557748352e6b496a6a5031492f6631634c4f6d6d682e7674375635552f6e48304b667a37'
<<<<<<< HEAD
            @url = 'https://api.apigw.smt.docomo.ne.jp/virtualNarrator/v1/textToSpeech?APIKEY=' + @apiKey

=======
            @url = 'https://api.apigw.smt.docomo.ne.jp/voiceText/v1/textToSpeech?APIKEY=' + @apiKey
            # @url = 'https://api.apigw.smt.docomo.ne.jp/virtualNarrator/v1/textToSpeech?APIKEY=' + @apiKey

            @form = doc.forms['post-form']
>>>>>>> master
            @initialize()

        initialize: ->

<<<<<<< HEAD
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
=======
        synth: (text, chara) ->
            # console.log sex
            self = @
            # postData =
            #     Command: "AP_Synth"
            #     TextData: text
            #     SpeakerID: sex
            #     SpeechRate: '1.00'
            #     PowerRate: '1.00'
            #     VoiceType: '0'
            #     AudioFileFormat: '0'
            postData =
                text: text
                speaker: chara
                # emotion: ''
                # emotion_level: '1'
                pitch: '100'
                speed: '100'
                volume: '100'
                format: 'wav'

            xhr = new XMLHttpRequest()

>>>>>>> master

            #------- [1] -------
            xhr.responseType = 'arraybuffer'

<<<<<<< HEAD
            xhr.setRequestHeader("Content-Type", "application/json; charset=utf-8")

=======
>>>>>>> master
            xhr.onload = ->
                if @readyState == 4 and this.status == 200
                    #------- [2] -------
                    view = new Uint8Array(@response)

                    #------- [3] -------
                    blob = new Blob([view], { "type" : "audio/wav" })
                    self.data.blob = blob
                    self.emit('synth', blob)

                    #------- [4] -------

<<<<<<< HEAD
            xhr.send(JSON.stringify(postData))
=======
            xhr.onerror = (e) ->
                # エラー処理
                console.log 'XHR ERROR: ', e

            xhr.open('POST', @url)

            # xhr.setRequestHeader("Content-Type", "application/json; charset=utf-8")
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")

            # xhr.send(JSON.stringify(postData))
            xhr.send($.param(postData))
>>>>>>> master


    class AppModel extends Events

        constructor: (profile, special) ->
            super()
            @data =
                context: ''
            @profile = profile
            @special = _.shuffle(special)

            @apiKey = '6c612e594d5a32557748352e6b496a6a5031492f6631634c4f6d6d682e7674375635552f6e48304b667a37'
            @url = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=' + @apiKey

            @count = 0
            @max = 3

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
            postData = _.extend(@profile, { utt: text, context: CONTEXT })

            $.ajax(
                type: 'post'
                url: @url
                contentType: 'application/json; charset=utf-8'
                dataType: 'json'
                data: JSON.stringify(postData)
            ).done((data) =>
                @data = data
                CONTEXT = data.context
                @emit('fetch', data)
            )

        think: (text) ->
<<<<<<< HEAD
            console.log @profile.sex
            if @profile.sex is "女"
                sex = '0'
            else if @profile.sex is "男"
                sex = '1'

=======
>>>>>>> master
            @count++
            if @count is 3 and @special.length > 0
                @count = 0
                text = @special[@rand(1, @special.length)]
                @data.utt = text
                CONTEXT = ''

<<<<<<< HEAD
            @synth.synth(@data.utt, sex)
=======
            @synth.synth(@data.utt, @profile.chara)
>>>>>>> master

        say: (blob) ->
            @voice.set(blob).play()

        rand: (min, max) ->
            return min + Math.floor(Math.random() * (max + 1 - min))

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
<<<<<<< HEAD
=======
        chara: 'santa'
>>>>>>> master
        bloodtype: 'A'
        birthdateY: '1985'
        birthdateM: '4'
        birthdateD: '1'
        age: '30'
        constellations: '牡羊座'
        place: '横浜'
        mode: 'dialog'
<<<<<<< HEAD
        t: '30'
    , [
        '好きです',
        'どうして、そんなにおれの好きな顔に生まれてきたの？',
        'たまには俺にリードさせてくださいよ。',
        'カナちゃんが彼女になってよ。',
        'いいから俺についてこい。',
        '俺にしとけば？',
        'もう、ほっとけないなー。',
        '守ってあげたいタイプってよく言われない？',
        '僕のものになってください！',
        '毎朝俺のために味噌汁を作ってください。',
        '俺と夜の大運動会で棒入れをしないかい？',
=======
        t: ''
    , [
        '大丈夫だって安心しろよ～',
        '先輩！何してんすか！やめてくださいよ本当に！',
        'ぱっかーーーん',
        #'好きです',
        #'どうして、そんなにおれの好きな顔に生まれてきたの？',
        #'たまには俺にリードさせてくださいよ。',
        #'いいから俺についてこい。',
        #'俺にしとけば？',
        #'もう、ほっとけないなー。',
        #'守ってあげたいタイプってよく言われない？',
        #'僕のものになってください！',
        #'毎朝俺のために味噌汁を作ってください。',
        #'俺と夜の大運動会で棒入れをしないかい？',
>>>>>>> master
    ])
    female = new AppModel(
        nickname: '倉科カナ'
        nickname_y: 'カナチャン'
        sex: '女'
<<<<<<< HEAD
=======
        chara: 'bear'
>>>>>>> master
        bloodtype: 'A'
        birthdateY: '1985'
        birthdateM: '3'
        birthdateD: '19'
        age: '30'
        constellations: '牡羊座'
        place: '東京'
        mode: 'dialog'
        t: ''
    , [])

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
<<<<<<< HEAD
=======


>>>>>>> master
