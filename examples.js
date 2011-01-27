function doStuff(foo, bar) {
  // ...
}

function ajax(url, callback) {
  // ...
}

function runApp() {
  getData(doStuff);
}

function getData(callback) {
  ajax('/foo', function(result) {
    var foo = extractFoo(result);
    ajax('/bar', function(result) {
      var bar = extractBar(result);
      callback(foo, bar);
    });
  });
}

function ajax2(url) {
  return function(callback) { return ajax(url, callback); };
}

function getBaz(foo) {
  return ajax2(bazUrl(foo));
}

var getData = group(sequence(converter(extractFoo)(ajax2('/foo')), getBaz),
                    converter(extractBar)(ajax2('/bar')));
