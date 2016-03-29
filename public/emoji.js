(function(emojione) {
  emojione.ascii = true;

  // custom emojis
  var toImage = function(shortname, path) {
    return '<img class="emojione" alt="' + shortname + '" src="' + path + '"/>';
  }

  var exp = /\:\S+\:/g;

  var aliases = {
    // polyfill :simple_smile:
    ':simple_smile:': emojione.shortnameToImage(':smile:'),
    // custom emojis
    ':argentina:': toImage('argentina', '//emoji.slack-edge.com/T02G2SXKM/argentina/7edefcbf1137a4a7.png'),
    ':camelia:': toImage('camelia', '//emoji.slack-edge.com/T02G2SXKM/camelia/7ec41b1d6e505ed5.png'),
    ':ciudadanos:': toImage('ciudadanos', '//emoji.slack-edge.com/T02G2SXKM/ciudadanos/445a92dbd1d3ddec.png'),
    ':dig:': toImage('dig', '//emoji.slack-edge.com/T02G2SXKM/dig/85baf0e2036d1839.png'),
    ':doraemon:': toImage('doraemon', '//emoji.slack-edge.com/T02G2SXKM/doraemon/2d732d31fb7fecc2.png'),
    ':drone:': toImage('drone', '//emoji.slack-edge.com/T02G2SXKM/drone/ef50b60f6bcf9b85.png'),
    ':eff:': toImage('eff', '//emoji.slack-edge.com/T02G2SXKM/eff/b75b6ec360e98b44.png'),
    ':er:': toImage('er', '//emoji.slack-edge.com/T02G2SXKM/er/3fca34007737150f.png'),
    ':explode:': toImage('explode', '//emoji.slack-edge.com/T02G2SXKM/explode/b3c7f43e35c7c4a6.png'),
    ':fill:': toImage('fill', '//emoji.slack-edge.com/T02G2SXKM/fill/feecb268616fac64.png'),
    ':fire-app:': toImage('fire-app', '//emoji.slack-edge.com/T02G2SXKM/fire-app/46c79c974499f596.png'),
    ':g0v:': toImage('g0v', '//emoji.slack-edge.com/T02G2SXKM/g0v/541e38dfc833f04b.png'),
    ':good:': toImage('good', '//emoji.slack-edge.com/T02G2SXKM/good/07fd0c2ba40f8742.png'),
    ':gossip:': toImage('gossip', '//emoji.slack-edge.com/T02G2SXKM/gossip/96e2be9b42cde4ab.png'),
    ':hack:': toImage('hack', '//emoji.slack-edge.com/T02G2SXKM/hack/d341974c3bafe01e.png'),
    ':harvest:': toImage('harvest', '//emoji.slack-edge.com/T02G2SXKM/harvest/116db7132d8df678.png'),
    ':iing:': toImage('iing', '//emoji.slack-edge.com/T02G2SXKM/iing/647af0b60f519370.png'),
    ':itaigi:': toImage('itaigi', '//emoji.slack-edge.com/T02G2SXKM/itaigi/3c51c35ee4910cc0.png'),
    ':jia:': toImage('jia', '//emoji.slack-edge.com/T02G2SXKM/jia/4dc0e23b86e04175.png'),
    ':jian:': toImage('jian', '//emoji.slack-edge.com/T02G2SXKM/jian/6b380b3a25a97edf.png'),
    ':logical:': toImage('logical', '//emoji.slack-edge.com/T02G2SXKM/logical/7625ad6131bc9333.jpg'),
    ':moe:': toImage('moe', '//emoji.slack-edge.com/T02G2SXKM/moe/7c0c216031bbd9d5.png'),
    ':orz:': toImage('orz', '//emoji.slack-edge.com/T02G2SXKM/orz/55d8860226f3633c.jpg'),
    ':moedict:': toImage('moedict', '//emoji.slack-edge.com/T02G2SXKM/moedict/691ce437903431c1.png'),
    ':pangcah:': toImage('pangcah', '//emoji.slack-edge.com/T02G2SXKM/pangcah/424a8a4d546619ee.png'),
    ':people:': toImage('people', '//emoji.slack-edge.com/T02G2SXKM/people/895151e404360764.png'),
    ':podemos:': toImage('podemos', '//emoji.slack-edge.com/T02G2SXKM/podemos/2025801af044ab0a.png'),
    ':rmstudio:': toImage('rmstudio', '//emoji.slack-edge.com/T02G2SXKM/rmstudio/0319f06bfaaf8061.png'),
    ':strange:': toImage('strange', '//emoji.slack-edge.com/T02G2SXKM/strange/913f9d05e124cca9.png'),
    ':tainan:': toImage('tainan', '//emoji.slack-edge.com/T02G2SXKM/tainan/fc32446eeebd6381.png'),
    ':taipei:': toImage('taipei', 'https://emoji.slack-edge.com/T02G2SXKM/taipei/d87c404876fa7c6e.png'),
    ':talktotw:': toImage('talktotw', '//emoji.slack-edge.com/T02G2SXKM/talktotw/f571db7315e8e681.png'),
    ':tip1:': toImage('tip1', '//emoji.slack-edge.com/T02G2SXKM/tip1/45d40312cff5396d.jpg'),
    ':tip2:': toImage('tip2', '//emoji.slack-edge.com/T02G2SXKM/tip2/928695365c2dd78d.jpg'),
    ':twreporter:': toImage('twreporter', '//emoji.slack-edge.com/T02G2SXKM/twreporter/e54ce0a06a8a5702.png'),
    ':vote:': toImage('vote', '//emoji.slack-edge.com/T02G2SXKM/vote/69c25a68b089e67d.png')
  };

  var emoji = function(msg) {
    var result;
    var alias;

    msg = emojione.toImage(msg);

    while (result = exp.exec(msg)) {
      result = result[0];
      alias = aliases[result] || result;
      msg = msg.replace(result, alias);
    }

    return msg;
  }

  window.emoji = emoji;
}(emojione));
