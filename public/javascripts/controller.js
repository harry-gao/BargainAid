$().ready(function () {
    $("#trans_area").load(function () { //The function below executes once the iframe has finished loading
        $.getJSON('/home/get_price', function(data) {
		  //$('.result').html(data);
		  //alert(JSON.stringify(data));
                  got(data.item_price);
		});
    });
});


function setClass(eleId, className)
{
    document.getElementById(eleId).className=className;
}

function got(price)
{
   
    if(price == "none" || price =='' )
    {
        $("#result_tab").html("<p>This seems not an item</p>\n\
            <p>please continue to find your interested item</p>")
    }
    else
    {
        $("#result_tab").html("<p> Original Price: " + price + "</p>\n\
            <p>Estimated Cost:</p>");
    }
    setClass("result_area", "got");
}

