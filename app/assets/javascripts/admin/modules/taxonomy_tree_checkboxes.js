(function(Modules) {
  "use strict";

  Modules.TaxonomyTreeCheckboxes = function() {
    this.start = function(element) {
      $(element).on('click', 'input:checkbox', function() {

        var checked = $(this).is(":checked");

        if (checked) {
          var $parents = $(this).parents('.topics,.topic-tree');
          $parents.each(function(){
            $(this).prev('p').find('input[type="checkbox"]').prop('checked', true);
          });
        } else {
          $(this).closest('p').next('.topics').find('input[type="checkbox"]').prop('checked', false);
        }
      });
    };
  };

})(window.GOVUKAdmin.Modules);
