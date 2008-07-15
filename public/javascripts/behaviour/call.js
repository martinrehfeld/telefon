window.Telefon = window.Telefon || {};
Telefon.CallBehaviour = function(){

  // activate destination field for immediate entry
  function activateInputField(){
    Form.Element.activate('call_destination');
    if($('call-history-headline')) { $('call-history-headline').show(); }
  }
    
  // populate call history if present
  function populateCallHistory(){
    if($('call-history-placeholder')) {
      new Ajax.Updater('call-history-placeholder', this.sourceUrl, {
        asynchronous:true,
        evalScripts:true,
        method:'get',
        onLoading: function(request){
          $('call-history-busy').style.visibility = 'visible';
        },
        onComplete: function(request){
          $('call-history-busy').style.visibility = 'hidden';
          makePhoneNumbersClickable();
          new Effect.BlindDown("call-history-placeholder",{duration:3.0});
        }
      });
    }
  }
  
  // attach event handler
  function makePhoneNumbersClickable() {
    $$('.phone-number', '.phone-name').each(function(e) {
      e.addClassName('clickable');
    });
    $('call-history').observe('click', clickHandler);
  }

  // event handler for clicks in call history
  function clickHandler(event) {
    var element = event.element();

    if(element.hasClassName('phone-name')) {
      element = event.element().previous('.phone-number');
    }
    if(element.hasClassName('phone-number')) {
      $('call_destination').value = element.innerHTML;
      $('top').scrollTo();
      Form.Element.activate('call_destination');
      event.stop();
    }
  }

  // public properties / methods
  return {
    autoPopulate: true,
    attach: makePhoneNumbersClickable,
    populate: populateCallHistory,
    sourceUrl: '/call-history',
    init: function(options){
      var self = Telefon.CallBehaviour;
      if(options) { Object.extend(self, options); }
      activateInputField();
      if(self.autoPopulate) { self.populate(); }
    }
  };

}();
