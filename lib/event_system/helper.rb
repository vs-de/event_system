module EventSystem
  module Helper
    UPDATE_URL_SUFFIX='"?last_load="+$("#event_system_last_load").text()'
    def integrate_event_system opts = {:strict_timer => false}
      if controller.class.method_defined?("updates_for_#{action_name}")
        url = url_for :controller => controller_name, :action => "updates_for_#{action_name}"
        interval = controller.event_system_update_interval 
        js_tag = opts[:strict_timer] ? strict_tag(url, interval) : lazy_tag(url, interval)
        "<span id='event_system_last_load' style='display: none;'>#{@controller.current_event_number = EventSystem::IndicatorSequence.current}</span>"+js_tag
      else
        ""
      end
    end
    
    #strictly fires the loader every nth second
    def strict_tag url, interval
      javascript_tag(
        "$(document).ready(function() {
        	setInterval(function() {getNewEvents('#{url}');}, #{interval*1000});
	});
	function getNewEvents(url) {
           	url = url+#{UPDATE_URL_SUFFIX};
           	$.getScript(url);
         };
	 "
        )
    end
    
    #adds time needed until success reached
    # this is more smooth on heavy load
    def lazy_tag url, interval
      javascript_tag(
        "var event_timer;
         var url = '#{url}';
	 function getNewEvents() {
	   $.getScript(url+#{UPDATE_URL_SUFFIX}, function() {
	     event_timer = setTimeout('getNewEvents()', #{interval*1000});
	   });
	 };
	 $(document).ready(function() {
	      getNewEvents();
	 });
        "
      )
    end
  end
end
