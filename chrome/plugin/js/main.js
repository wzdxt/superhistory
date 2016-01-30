(function() {
    if (location.protocol == "http:")
        var host = "http://localhost:3000";
    else
        var host = "https://localhost:3031";
    var visit_id;
    $.post(host + "/visits", {}, function(data) {
        visit_id = data;
    });

    window.onbeforeunload = (function(){
        if (visit_id !== undefined && !isNaN(visit_id)) {
            $.post(host + "/visits/" + visit_id + "/close", {_method:"put"});
        }
    });
})();
