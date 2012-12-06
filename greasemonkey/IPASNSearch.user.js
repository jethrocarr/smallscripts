// ==UserScript==
// @name        IP-ASN-Search
// @namespace   ip-asn-search.jethrocarr.com
// @description Searches IP-ASN list pages
// @include     *
// @grant	GM_getResourceText
// @version     1
// @resource	matchlist	http://example.com/matchlist.txt
// ==/UserScript==

/*
	This script is written to easily search text files against a list of supplied IP addresses or ASN numbers
	and highlights matching results on the page.

	CURRENTLY THIS IS VERY ALPHA, MAY EAT BABIES, CAUTION ADVISED.

	Written by Jethro Carr <jethro.carr@jethrocarr.com>
*/


/*
	Application Configuration.

	IMPORTANT: most likely you just want to change what file is being opened as the source match
	list. This can be done on LINE 7  by adjusting the "matchlist" parameter.
*/

var config_color = "yellow";


try
{
	var matchSource	= GM_getResourceText("matchlist");
	var matchArray	= matchSource.split("\n");

	//unsafeWindow.console.log(matchSource);
}
catch(err)
{
	unsafeWindow.console.log("Error "+ err.message);
	alert("There was an error loading resource matchlist: "+ err.message +"\n");
}

//var matchArray = new Array("19840202", "00000000", "2620:14f::", "131.178.0.0", "A91E66F2");



/*
	Support Functions
*/
function strpos (haystack, needle, offset)
{
	var i = (haystack+'').indexOf(needle, (offset || 0));
	return i === -1 ? false : i;
}


/*
	Main
*/

var documentText = document.body.innerHTML;

// strip out any <pre>...</pre> tags
documentText = documentText.replace(/<pre>|<\/pre>/, "");

// split each line for easier processing
var documentArray = documentText.split("\n");



// check the first line for IP-ASN formatting - if it doesn't match, we should terminate now,
// otherwise we run the risk of trawling through huge unrelated files.
//
// we need to be clever here and skip past any obvious headers at the top of the file to the first numercial line, we
// do this with a basic value match to find the first real line of the page.

var check_index = 0;
var check_index_set = 0;

documentArray.some(function(value, index)
{
	if (!value.match(/^#/))
	{
		// TODO: this should be getting handled with a break, but it seems Javascript doesn't have the concept of one :'(
		// TODO: fixing this would increase performance theoretically

		if (!check_index_set)
		{
			check_index = index;
			check_index_set = 1;
		}
	}
});



if (documentArray[check_index].match(/\S*\|\S*\|[0-9]*\|[0-9]*\|[0-9]*\|[0-9]*\|\S*/))
{
	// matches the expected header. This should work for any text files loaded directly by the browser,
	// but will break badly if the page had some other headers in it, or even if it's HTML based.

	documentArray.forEach(function(value, index)
	{
	//	unsafeWindow.console.log("Line: " + value );
		matchArray.forEach(function(mvalue, mindex)
		{	
			if (strpos(value, mvalue))
			{
				documentArray[index] = "<span style=\"background-color: "+ config_color + ";\">"+ value +"</span>";
			}
			
			//unsafeWindow.console.log("mvalue "+mvalue+" value "+value+" :: "+documentArray[index]);
		});
	});


	// re-assemble and apply changes to document
	document.body.innerHTML = "<pre><span style=\"background-color: "+ config_color +";\">APPLIED AUTOMATIC IP-ASN SEARCH FILTER</span>\n\n"+ documentArray.join("\n")  +" </pre>";
}
else
{
	//unsafeWindow.console.log("Non-matching file (index "+ check_index +")");
}

