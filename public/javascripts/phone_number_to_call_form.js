// make all phone-numbers clickable, entering their value into the new_call form

Event.observe(window, 'load', function(){
  $$('.phone-number').each(function(e) {
    e.observe('click', respondToPhoneNumberClick);
  });
});

function respondToPhoneNumberClick(event) {
  if(event.isLeftClick()) {
    call_destination = $$('form.new_call').first()['call_destination'];
    call_destination.value = event.element().innerHTML.gsub(/\+/,'').gsub(/ /,'');
    new Effect.ScrollTo('top');
    call_destination.activate();
  }
}