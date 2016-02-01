(function () {
    var ajaxRequest = function (method, url, data, callback) {
        chrome.runtime.sendMessage({
            method: method,
            action: 'xhttp',
            url: url,
            data: $.param(data)
        }, function (responseText) {
            callback(responseText);
        });
    };
    var host = "http://localhost:3000";
    var referer = location.protocol + "//" + location.host + location.pathname;
    var visit_id;

    ajaxRequest("post", host + "/visits", {referer:referer}, function (data) {
        visit_id = data;
    });

    window.onbeforeunload = (function () {
        if (visit_id !== undefined && !isNaN(visit_id)) {
            ajaxRequest("post", host + "/visits/" + visit_id + "/close", {_method:"patch", referer: referer});
        }
    });
})();

