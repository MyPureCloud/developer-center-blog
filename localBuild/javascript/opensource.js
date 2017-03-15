var hasErrors = false;

$(document).ready(function() {
	var repoUrl = getParameterByName('repoUrl');
	if (repoUrl == '') return;
	$('input#repoUrl').val(repoUrl);
});

function showRepos(attribute) {
	$('div.oss-content-panel').slideUp(500);
	if (attribute)
		setTimeout(function(){$('div.oss-content-panel.'+attribute).slideDown(500);},550);
	else
		setTimeout(function(){$('div.oss-content-panel').slideDown(500);},550);
}

function validateDataFile() {
	// Start with a clean slate
	clearValidationDisplay();

	// init
	var repoUrl = $('input#repoUrl').val();

	// :)
	var matches = getMatches(repoUrl, new RegExp(/(https:\/\/raw.githubusercontent.com\/(?:.+?\/){3}ossindex\.json)/g), 1);
	if (matches.length == 1){
		$.ajax(repoUrl, {
			method: 'GET',
			cache: false,
			success: function(data, textStatus, jqXHR) {
				console.debug(data);
				console.debug(textStatus);
				console.debug(jqXHR);
				validateDataFileContents(JSON.parse(data));
				if (!hasErrors)
					writeValidationMessage('Data file validated! Looking for a job? Head over to <a href="http://inin.jobs">http://inin.jobs</a>.', 'success');
				$('#oss-datafile-content-pre').html(JSON.stringify(JSON.parse(data), 0, 2));
				$('#oss-datafile-content').fadeIn(700);
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.error(errorThrown);
				console.debug(jqXHR);
				console.debug(textStatus);
				writeValidationMessage('Error getting data file: ' + errorThrown, 'error');
			}
		});
		return;
	}
	
	// Parse URL
	if (!repoUrl.endsWith('/')) repoUrl += '/';
	matches = getMatches(repoUrl, new RegExp(/(.+?)\//g), 1);

	// Validate
	if (matches == null || matches.length != 4) {
		writeValidationMessage('Invalid repo URL. Use the base URL that looks like https://github.com/&lt;account>/&lt;repo>', 'error');
		return;
	}
	if (matches[1].toLowerCase() != '/github.com') {
		writeValidationMessage('Invalid repo URL. Is your repo hosted at github.com? Use the base URL that looks like https://github.com/&lt;account>/&lt;repo>',error);
		return;
	}

	// Appears to be valid
	var account = matches[2];
	var repoName = matches[3];

	// Get data file
	// This is done using replacement so the CDN_URL doesn't get injected here
	var dataFileUrl = 'https://api.github.com/repos/{{account}}/{{repoName}}/contents/ossindex.json';
	dataFileUrl = dataFileUrl.replace('{{account}}',account).replace('{{repoName}}',repoName);
	console.debug(dataFileUrl);
	$.ajax(dataFileUrl, {
		method: 'GET',
		cache: false,
		headers: {
			Accept: 'application/vnd.github.v3.raw+json'
		},
		success: function(data, textStatus, jqXHR) {
			console.debug(data);
			console.debug(textStatus);
			console.debug(jqXHR);
			validateDataFileContents(data);
			if (!hasErrors)
				writeValidationMessage('Data file validated! A winner is you!', 'success');
			$('#oss-datafile-content-pre').html(JSON.stringify(data, 0, 2));
			$('#oss-datafile-content').fadeIn(700);
		},
		error: function(jqXHR, textStatus, errorThrown) {
			console.error(errorThrown);
			console.debug(jqXHR);
			console.debug(textStatus);
			writeValidationMessage('Error fetching data file: ' + errorThrown, 'error');
		}
	});
}

function validateDataFileContents(data) {
	validateDataFileProperty(data, 'author');
	validateDataFileProperty(data, 'title');
	validateDataFileProperty(data, 'logo_url', true);
	validateDataFileArray(data, 'categories');
	validateDataFileArray(data, 'tags', true);
	validateDataFileArray(data, 'apis');
	validateDataFileArray(data, 'sdks', true);
}

function validateDataFileProperty(data, propertyName, isOptional) {
	if (data[propertyName] == undefined || data[propertyName].trim() == '') {
		if (isOptional === true)
			writeValidationMessage('Consider adding optional property: ' + propertyName, 'warning');
		else
			writeValidationMessage('Missing required property: ' + propertyName, 'error');
	}
}

function validateDataFileArray(data, propertyName, isOptional) {
	if (data[propertyName] == undefined || data[propertyName].constructor != Array || data[propertyName].length == 0) {
		if (isOptional === true)
			writeValidationMessage('Consider adding optional array property: ' + propertyName, 'warning');
		else
			writeValidationMessage('Missing required array property: ' + propertyName, 'error');
	}
}

function writeValidationMessage(message, cssClass){
	if (cssClass == 'error') hasErrors = true;
	var id = 'message-' + Math.floor(Math.random() * 1000000);
	$('div#oss-validation-output').show();
	$('div#oss-validation-messages').append('<span id="' + id + '" class="oss-' + cssClass + '" style="display:none">' + message + '</span>');
	$('span#' + id).fadeIn(700);
}

function getMatches(string, regex, index) {
  index || (index = 1); // default to the first capturing group
  var matches = [];
  var match;
  while (match = regex.exec(string)) {
    matches.push(match[index]);
  }
  return matches;
}

function clearValidationDisplay() {
	$('div#oss-validation-output').hide();
	$('#oss-datafile-content').hide();
	$('#oss-datafile-content-pre').html('');
	$('div#oss-validation-messages').html('');
	hasErrors = false;
}

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    url = url.toLowerCase(); // This is just to avoid case sensitiveness  
    name = name.replace(/[\[\]]/g, "\\$&").toLowerCase();// This is just to avoid case sensitiveness for query parameter name
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}