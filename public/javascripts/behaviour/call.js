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
  
  // event handler for clicks in call history
  function clickHandler(event) {
    var element = event.element();

    if(element.hasClassName('phone-name')) {
      element = event.element().previous('.phone-number');
    }
    if(element.hasClassName('phone-number')) {
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
      $('call-history').observe('click', clickHandler);
    },

    init: function(options) {
      // make sure we are using the right scope even if we are called with this set to some other object
      var self = Telefon.CallBehaviour;

      if(options != undefined) { Object.extend(self, options); }
      activateInputField();
      if(self.autoPopulate) { self.populate(); }
    }
  };

})();
