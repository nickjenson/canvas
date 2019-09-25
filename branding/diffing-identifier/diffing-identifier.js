$(document).ready(function() {
  if (window.location.pathname == "/accounts/1/sis_import") {
    $('#stickiness_options').after('<div id="diffing_data_set_options">\
			<div id="diffing_data_set_container">\
				<div class="ic-Form-control">\
					<input type="textbox" name="diffing_data_set_identifier" value="" id="diffing_data_set_identifier" placeholder="i.e. 2019-Fall-01">\
					<label for="diffing_data_set_identifier">Diffing Set Identifier (leave blank for none)</label><br>\
					<input type="checkbox" name="diffing_remaster_data_set" value="true" id="diffing_remaster_data_set">\
					<label for="diffing_remaster_data_set">Remaster Diffing Set</label>\
				</div>\
			</div>\
		</div>');
  }
});