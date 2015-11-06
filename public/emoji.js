(function(emojione) {
  // source: http://stackoverflow.com/questions/28077049/regex-matching-emoticons
  var exp = /(\:\w+\:|\<[\/\\]?3|[\(\)\\\D|\*\$][\-\^]?[\:\;\=]|[\:\;\=B8][\-\^]?[3DOPp\@\$\*\\\)\(\/\|])(?=\s|[\!\.\?]|$)/g;
  var aliases = {
    ":simple_smile:": ":smile:",
    "<3": ":heart:"
  };

  var emoji = function(msg) {
    var result;
    var alias;

    while (result = exp.exec(msg)) {
      result = result[0];
      alias = aliases[result] || result;
      msg = msg.replace(result, emojione.toImage(alias));
    }

    return msg;
  }

  window.emoji = emoji;
}(emojione));
