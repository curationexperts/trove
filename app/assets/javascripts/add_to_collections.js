Blacklight.onLoad(function() {
  $('[data-behavior="draggable"]').draggable({
    helper: function(event) {
      return $('<span style="white-space:nowrap;"/>')
            .html($(this).find('img').clone().css('opacity', '0.6'));
    },
    cursorAt: { left: 5, top: 5 },
    // enable dropping onto child items that are collapsed (display: none) when dragging starts.
    refreshPositions: true
  }).click(function() {
    if ( $(this).is('.ui-draggable-dragging') ) {
      return;
    }

    $(this).find('a').click();
  });

  $('[data-behavior="not-draggable"]').draggable({
    helper: function(event) {
      return $('<div style="white-space:nowrap; height: 64px; width: 64px" class="no-drag"></div>')
    },
    cursorAt: { left: 5, top: 5 },
  }).click(function() {
    if ( $(this).is('.ui-draggable-dragging') ) {
      console.log("dragging");
      return;
    }

    $(this).find('a').click();
  });

  function addToPersonalCollection(event, ui) {
    addToCollection(event, ui, 'personal_collections')
  }

  function addToCourseCollection(event, ui) {
    addToCollection(event, ui, 'course_collections')
  }


  function addToCollection(event, ui, path) {
    pid = ui.draggable.data('document-id');
    collection_id = $(event.target).data('id');
    $.ajax({
      type: "PATCH",
      url: '/' + path + '/' + collection_id + '/append_to',
      data: {pid: pid},
      success: function(data, status){
      }
    });
  }

  var clearDropClassOnParent = function(item, level) {
    if (that.data('level') == '2' ) {
      setTimeout(function () {
        that.closest('[data-level="1"]').removeClass('drop-target-hover');
      }, 1);
    } else { // level 3
      setTimeout(function () {
        that.closest('[data-level="1"]').removeClass('drop-target-hover');
        that.closest('[data-level="2"]').removeClass('drop-target-hover');
      }, 1);
    }
  }

  var hoverIntent;
  // Handler when the mouse goes over a droppable.
  var mouseEnter = function() {
    // Ensure the parent item doesn't also have drop-target-hover
    // This is importing if you're hoving over a child collection.
    that = $(this)
    if (that.data('level') != '1' ) {
      clearDropClassOnParent(that, that.data('level'))
    }

    if (!$(this).hasClass('dd-collapsed')) {
      return true;
    }

    // Start a timeout to expand the child items.
    hoverIntent = setTimeout( function() {
      that.closest('.dd').data('nestable').expandItem(that)
    } , 800 );

    return true;
  }

  // Handler for when the mouse leaves a droppable
  var mouseLeave = function () {
    clearTimeout(hoverIntent);
  }


  var opts = {
    greedy: true,
    hoverClass: 'drop-target-hover',
    over: mouseEnter,
    out: mouseLeave,
    tolerance: 'pointer',
    accept: '[data-behavior="draggable"]'
  };

  $(".personal-collection-list li.drop-target").droppable(
    $.extend({drop: addToPersonalCollection}, opts)
  );
  $(".course-collection-list li.drop-target").droppable(
    $.extend({drop: addToCourseCollection}, opts)
  );
});
