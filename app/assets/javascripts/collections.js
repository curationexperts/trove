// This script is responsible for ordering/nesting the collections in the sidebar

Blacklight.onLoad(function(){
  $('#orderable-course-collections, #orderable-personal-collections').nestable({ maxDepth: 3 });
  updateWeightsAndRelationships($('#orderable-course-collections, #orderable-personal-collections'));
});

function updateWeightsAndRelationships(selector){
  $.each(selector, function() {
    $(this).on('change', function(event){
      // Scope to a container because we may have two orderable sections on the page (e.g. About page has pages and contacts)
      updateTopLevel($(this).nestable('serialize'), $(event.currentTarget));
    });
  });
}

function updateTopLevel(data, container) {
  var weight = 0;
  for(var i in data){
    updateSingleNode(data[i], container, weight++)
  }
}

function updateSingleNode(data, container, weight) {
  var id = data['id'];
  node = findNode(id, container);
  setWeight(node, weight);
  if(data['children']){
    updateChildren(data['children'], container, id);
  } else {
    setParent(node, "");
  }
}

function updateChildren(data, container, parent_id) {
  console.log(data);
  var weight = 0;
  for(var i in data){
    updateSingleChild(data[i], container, parent_id, weight++)
  }
}

function updateSingleChild(data, container, parent_id, weight) {
  var id = data['id']
  node = findNode(id, container);
  setWeight(node, weight);
  setParent(node, parent_id);
  if(data['children']) {
    updateChildren(data['children'], container, id);
  } else {
    console.log("no children");
  }
}

function setParent(node, parent_id) {
  parent_page_field(node).val(parent_id);
}

/* find the input element with data-property="parent_page" that is nested under the given node */
function parent_page_field(node){
  return find_property(node, "parent_page");
}
