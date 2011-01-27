var Pipeline = {};
(function() {
  var aggregate = Pipeline.aggregate = function(actions) {
    var numResults = 0;
    var results = [];
    var gotError = false;
    function handleResults(callbacks) {
      numResults++;
      if (numResults === actions.length) {
        if (gotError) {
          callbacks.error();
        } else {
          callbacks.success(results);
        }
      }
    };

    return function(callbacks) {
      each(actions, function(action) {
        action({
          success: function(newResults) {
            results.push(newResults);
            handleResults(callbacks);
          },
          error: function() {
            gotError = true;
            handleResults(callbacks);
          }
        });
      });
    };
  };

  var converter = Pipeline.converter = function(conversion) {
    return function(action) {
      return function(callbacks) {
        action({
          success: function() {
            var result = conversion.apply(undefined, arguments);
            if (result && result.length && result.length > 1 && result.length == callbacks.success.length) {
              callbacks.success.apply(undefined, result);
            } else {
              callbacks.success(result);
            }
          },
          error: callbacks.error
        });
      };
    };
  };

  var concatenate = Pipeline.concatenate = converter(function(results) {
    return [].concat.apply([], results);
  });

  var group = Pipeline.group = function() {
    var actions = arguments;
    var numResults = 0;
    var results = [];
    var gotError = false;
    function handleResults(callbacks) {
      numResults++;
      if (numResults === actions.length) {
        if (gotError) {
          callbacks.error();
        } else {
          callbacks.success.apply(undefined, results);
        }
      }
    };

    return function(callbacks) {
      each(actions, function(action, index) {
        action({
          success: function(newResults) {
            results[index] = newResults;
            handleResults(callbacks);
          },
          error: function() {
            gotError = true;
            handleResults(callbacks);
          }
        });
      });
    };
  };
});
