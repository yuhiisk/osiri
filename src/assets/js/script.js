var $, Events,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

$ = require('./jquery.js');

Events = require('events').EventEmitter;

(function(win, doc) {
  'use strict';

  /*
   * Model
   */
  var AppModel, AudioPlayer, ChatView, InputView, SpeechSynth, chatView, female, inputView, male;
  SpeechSynth = (function(superClass) {
    extend(SpeechSynth, superClass);

    function SpeechSynth() {
      SpeechSynth.__super__.constructor.call(this);
      this.data = {
        blob: null
      };
      this.apiKey = '6c612e594d5a32557748352e6b496a6a5031492f6631634c4f6d6d682e7674375635552f6e48304b667a37';
      this.url = 'https://api.apigw.smt.docomo.ne.jp/virtualNarrator/v1/textToSpeech?APIKEY=' + this.apiKey;
      this.initialize();
    }

    SpeechSynth.prototype.initialize = function() {};

    SpeechSynth.prototype.synth = function(text, sex) {
      var postData, self, xhr;
      self = this;
      postData = {
        Command: "AP_Synth",
        TextData: text,
        SpeakerID: sex,
        SpeechRate: '1.00',
        PowerRate: '1.00',
        VoiceType: '0',
        AudioFileFormat: '0'
      };
      xhr = new XMLHttpRequest();
      xhr.open('POST', this.url, true);
      xhr.responseType = 'arraybuffer';
      xhr.setRequestHeader("Content-Type", "application/json; charset=utf-8");
      xhr.onload = function() {
        var blob, view;
        if (this.readyState === 4 && this.status === 200) {
          view = new Uint8Array(this.response);
          blob = new Blob([view], {
            "type": "audio/wav"
          });
          self.data.blob = blob;
          return self.emit('synth', blob);
        }
      };
      return xhr.send(JSON.stringify(postData));
    };

    return SpeechSynth;

  })(Events);
  AppModel = (function(superClass) {
    extend(AppModel, superClass);

    function AppModel(profile) {
      AppModel.__super__.constructor.call(this);
      this.data = {
        context: ''
      };
      this.profile = profile;
      this.apiKey = '6c612e594d5a32557748352e6b496a6a5031492f6631634c4f6d6d682e7674375635552f6e48304b667a37';
      this.url = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=' + this.apiKey;
      this.initialize();
    }

    AppModel.prototype.initialize = function() {
      this.synth = new SpeechSynth();
      this.synth.on('synth', (function(_this) {
        return function(blob) {
          return _this.emit('ready', blob);
        };
      })(this));
      this.voice = new AudioPlayer();
      return this.voice.on('ended', (function(_this) {
        return function(e) {
          return _this.emit('finished', e, _this.data.utt);
        };
      })(this));
    };

    AppModel.prototype.fetch = function(text) {
      var postData;
      postData = _.extend(this.profile, {
        utt: text,
        context: this.data.context
      });
      return $.ajax({
        type: 'post',
        url: this.url,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify(postData)
      }).done((function(_this) {
        return function(data) {
          _this.data = data;
          return _this.emit('fetch', data);
        };
      })(this));
    };

    AppModel.prototype.think = function(text) {
      var sex;
      console.log(this.profile.sex);
      if (this.profile.sex === "女") {
        sex = '0';
      } else if (this.profile.sex === "男") {
        sex = '1';
      }
      return this.synth.synth(this.data.utt, sex);
    };

    AppModel.prototype.say = function(blob) {
      return this.voice.set(blob).play();
    };

    return AppModel;

  })(Events);
  AudioPlayer = (function(superClass) {
    extend(AudioPlayer, superClass);

    function AudioPlayer() {
      this.initialize();
    }

    AudioPlayer.prototype.initialize = function() {
      this.audio = new Audio();
      return this.audio.addEventListener('ended', (function(_this) {
        return function(e) {
          return _this.emit('ended', e);
        };
      })(this), false);
    };

    AudioPlayer.prototype.getAudio = function() {
      return this.audio;
    };

    AudioPlayer.prototype.set = function(blob) {
      var URL;
      URL = window.URL || window.webkitURL;
      this.audio.src = URL.createObjectURL(blob);
      return this;
    };

    AudioPlayer.prototype.play = function() {
      this.audio.play();
      return this;
    };

    return AudioPlayer;

  })(Events);

  /*
   * View
   */
  ChatView = (function(superClass) {
    extend(ChatView, superClass);

    function ChatView(id) {
      if (id == null) {
        id = 'Chat';
      }
      this.el = doc.getElementById(id);
      this.initialize();
    }

    ChatView.prototype.initialize = function() {};

    ChatView.prototype.add = function(text) {
      var p, textNode;
      p = doc.createElement('p');
      textNode = doc.createTextNode(text);
      p.appendChild(textNode);
      return this.el.appendChild(p);
    };

    return ChatView;

  })(Events);
  InputView = (function(superClass) {
    extend(InputView, superClass);

    function InputView(id) {
      if (id == null) {
        id = 'Control';
      }
      this.el = doc.getElementById(id);
      this.input = this.el.querySelector('.control__input');
      this.submit = this.el.querySelector('.control__submit');
      this.initialize();
      this.eventify();
    }

    InputView.prototype.initialize = function() {
      return this.input.value = '';
    };

    InputView.prototype.eventify = function() {
      return this.submit.addEventListener('click', (function(_this) {
        return function(e) {
          _this.emit('submit', _this.input.value);
          return _this.input.value = '';
        };
      })(this), false);
    };

    return InputView;

  })(Events);

  /*
   * Entry Point
   */
  chatView = new ChatView();
  inputView = new InputView();
  male = new AppModel({
    nickname: 'いそっぷ',
    nickname_y: 'イソップ',
    sex: '男',
    bloodtype: 'A',
    birthdateY: '1985',
    birthdateM: '4',
    birthdateD: '1',
    age: '30',
    constellations: '牡羊座',
    place: '横浜',
    mode: 'dialog',
    t: '30'
  });
  female = new AppModel({
    nickname: 'いそっぷ',
    nickname_y: 'イソップ',
    sex: '女',
    bloodtype: 'A',
    birthdateY: '1985',
    birthdateM: '3',
    birthdateD: '19',
    age: '30',
    constellations: '牡羊座',
    place: '東京',
    mode: 'dialog',
    t: ''
  });
  inputView.on('submit', function(e) {
    chatView.add(e);
    return male.fetch(e);
  });
  male.on('fetch', function(data) {
    console.log('male fetch');
    return male.think(data.utt);
  });
  female.on('fetch', function(data) {
    console.log('female fetch');
    return female.think(data.utt);
  });
  male.on('ready', function(blob) {
    male.say(blob);
    return chatView.add(male.data.utt);
  });
  female.on('ready', function(blob) {
    female.say(blob);
    return chatView.add(female.data.utt);
  });
  male.on('finished', function(e, utt) {
    return female.fetch(utt);
  });
  return female.on('finished', function(e, utt) {
    return male.fetch(utt);
  });
})(window, window.document);
