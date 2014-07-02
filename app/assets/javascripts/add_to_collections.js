Blacklight.onLoad(function() {
  $(".document").draggable({
    helper: 'clone'
  });

  function addToPersonalCollection(event, ui) {
    addToCollection(event, ui, 'personal_collections')
  }

  function addToCourseCollection(event, ui) {
    addToCollection(event, ui, 'course_collections')
  }


  function addToCollection(event, ui, path) {
    pid = ui.draggable.data('document-id');
    collection_id = $(event.target).data('collection-id');
    $.ajax({
      type: "PATCH",
      url: '/' + path + '/' + collection_id + '/append_to',
      data: {pid: pid},
      success: function(data, status){
        console.log(data);
        console.log(status);
      }
    });
  }

  $(".personal-collection-list li.drop-target").droppable({
    hoverClass: 'drop-target-hover',
    tolerance: 'pointer',
    drop: addToPersonalCollection
  });
  $(".course-collection-list li.drop-target").droppable({
    hoverClass: 'drop-target-hover',
    tolerance: 'pointer',
    drop: addToCourseCollection
  });
});
