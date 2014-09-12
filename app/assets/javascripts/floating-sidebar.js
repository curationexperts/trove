// we have to use $(window) here because the height is dependent on images being loaded
$(window).load(scrollOnSearchResults);
// reinitialize everything for Turbolinks
$(document).on('page:load', scrollOnSearchResults);
// reinitialize everything for Turbolinks when the back button is pressed
$(document).on('page:restore', scrollOnSearchResults);

function scrollOnSearchResults(){
    pageSelector = '.blacklight-catalog-index:has(#documents:not(.slideshow))';
    content = $(pageSelector + ' #content');
    sidebar =  $(pageSelector + ' #sidebar');

    headerHeight = content.offset().top; //use the top of the main-content div to infer the height of the header
    viewPortHeightortHeight = window.innerHeight
        || document.documentElement.clientHeight
        || document.body.clientHeight;
    panelHeight = viewPortHeightortHeight - headerHeight;

    sidebar.height(panelHeight)
        .css('padding-right','15px')
        .css('margin-right','-15px')
        .css('overflow-y', 'auto')
        .css('position','relative');

    content.height(panelHeight)
        .css('padding-right','15px')
        .css('margin-right','-15px')
        .css('overflow-y', 'auto')
        .css('position','relative');

};
