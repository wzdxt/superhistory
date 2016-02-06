var func = (function (host) {
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
    var referer = location.toString();
    var visit_id;

    setTimeout(function() {
        ajaxRequest("post", host + "/visits", {referer:referer}, function (data) {
            visit_id = data;
        });
    }, 2000);

    window.onbeforeunload = (function () {
        if (visit_id !== undefined && (visit_id.length > 0) && !isNaN(visit_id)) {
            ajaxRequest("post", host + "/visits/" + visit_id + "/close", {_method:"patch", referer: referer});
        }
    });
});
func("http://localhost:3000");
func("http://x-history.vdtapp.com");

