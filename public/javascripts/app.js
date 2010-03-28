
function apply_stars(){
    $("#stars-wrapper").before("<textarea id='stars-message' name='message' rows='2' cols='50'>");
    $("#stars-wrapper").css("float", "right");
    $("#stars-wrapper").stars({
        inputType: "select",
        oneVoteOnly: true,
        callback: function(ui, type, value){
            $("#stars-loading").text("Loading...").fadeIn(2000);
            var target = /\?uri=(.+)/.exec(location.href)[1];
            var data = $("#rating-block form").serializeArray();
            var post_data = { uri: target };
            $.each(data, function(i, v){
                post_data[v.name] = v.value;
            });
            $("#rating-block form label").hide();
            $("#rating-block form input").hide();
            $("#stars-message").hide();
            $.post("/rate.json", post_data, function(data, status, xhr){
                $("#stars-loading").text("Finished!").fadeIn(2000);
            });
        }
    });
    $("#stars-with-message").change(function(e){
        $("#stars-message").toggle();
    });
}
