var Telefon = window.Telefon || {};
Telefon.CallBehaviour = (function(){

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
          Telefon.CallBehaviour.attach(); // attach event handler to loaded content
          new Effect.BlindDown('call-history-placeholder',{duration:3.0});
        }
      });
    }
  }
  
  // delegate event handler for clicks on calls page
  function clickHandler(event) {
    var element = event.element();
    
    // find the topmost element with the classes we are interested in
    element = element.ancestors().find(function(e){
      return e.hasClassName('phone-name') || e.hasClassName('phone-number');
    }) || element;

    // if a phone-name was clicked, find the matching phone-number
    if(element.hasClassName('phone-name')) {
      element = element.siblings().find(function(e){ return e.hasClassName('phone-number'); });
    }
    
    // process the event if a phone-number was targeted
    if(element && element.hasClassName('phone-number')) {
      $('call_destination').value = element.innerHTML.stripScripts().stripTags();
      $('top').scrollTo();
      Form.Element.activate('call_destination');
      event.stop();
    }
  }

  // public members
  return {
    // attributes
    autoPopulate: true,
    sourceUrl: '/call-history',
    
    // methods
    populate: populateCallHistory, // default to private static function defined above

    attach: function() {
      $$('.phone-number', '.phone-name').each(function(e) {
        e.addClassName('clickable');
      });
      $(document.body).observe('click', clickHandler);
    },

    init: function(options) {
      // make sure we are using the right scope even if we are called with this set to some other object
      var self = Telefon.CallBehaviour;

      if(options != undefined) { Object.extend(self, options); }
      activateInputField();
      self.attach();
      if(self.autoPopulate) { self.populate(); }
    }
  };

})();
