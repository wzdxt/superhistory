(function () {
    var ajaxRequest = function (method, url, data, callback) {
        chrome.runtime.sendMessage({
            method: method,
            action: 'xhttp',
            url: url,
            data: data
        }, function (responseText) {
            log(responseText);
            /*Callback function to deal with the response*/
        });
    };
    var host = "http://localhost:3000";
    var visit_id;

    //$.getJSON(host + "/visits/get", {}, function (data) {
    //    visit_id = data;
    //});
    ajaxRequest("GET", host + "/visits/get", {}, function (data) {
        visit_id = data;
    });

    window.onbeforeunload = (function () {
        if (visit_id !== undefined && !isNaN(visit_id)) {
            //$.getJSON(host + "/visits/" + visit_id + "/close", {});
            ajaxRequest("GET", host + "/visits/" + visit_id + "/close", {});
        }
    });

})();

