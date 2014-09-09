// we have to use $(window) here because the height is dependent on images being loaded
$(window).load(scrollOnSearchResults);
// reinitialize everything for Turbolinks
$(document).on('page:load', scrollOnSearchResults);
// reinitialize everything for Turbolinks when the back button is pressed
$(document).on('page:restore', scrollOnSearchResults);

function scrollOnSearchResults(){
  pageSelector = '.blacklight-catalog-index:has(#documents:not(.slideshow))';
  scroller = $(pageSelector + ' #sidebar')
  height = Math.max($(pageSelector + ' #content').height(), scroller.height());
  makeScrollable(scroller, height);
}

// Makes a div scrollable for a given height
function makeScrollable(scroller, height){
  scroller.find('*:first').css('margin-top', height);
  scroller.find('*:last').css('margin-bottom', height);
  scroller.height(height)
    .css('overflow', 'auto')
    .scrollTop(height);

  // called every time the window is scrolled
  handler = function(scrollAmount){
    scroller.scrollTop(scroller.scrollTop() - scrollAmount);
  }
  onWindowScroll(handler);
}

// a function that calls its handler with the change in offset for scrolling the window
onWindowScroll = (function(){
  doc = $(document);
  currentOffset = doc.scrollTop();
  scrollHandler = null;

  calculateAndSendDelta = function(){
    handler(doc.scrollTop() - currentOffset);
    currentOffset = doc.scrollTop();
  }

  return function(handler){
    currentOffset = doc.scrollTop();
    // have to use a local variable here because a closure will make calculateAndSendDelta
    // different every time and we won't be able to remove it when onWindowScroll is called
    // subsequent times
    scrollHandler = handler;
    // remove handler if it exists so we don't make duplicates
    doc.off('scroll', calculateAndSendDelta);
    doc.on('scroll', calculateAndSendDelta);
  }
})();
