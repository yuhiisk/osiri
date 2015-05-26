(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function(win, doc) {
  'use strict';
  var Test, test;
  Test = (function() {
    function Test() {
      this.initialize();
    }

    Test.prototype.initialize = function(name) {
      this.name = name != null ? name : 'Hello World!';
      return this.hello(this.name);
    };

    Test.prototype.hello = function(str) {
      return console.log(str);
    };

    return Test;

  })();
  return test = new Test();
})(window, window.document);



},{}]},{},[1]);
