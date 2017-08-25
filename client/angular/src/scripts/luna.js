/**
 * LUNA - Responsive Admin Theme
 *
 */
$(document).ready(function () {

    $("body").tooltip({ selector: '[data-toggle=tooltip]', container: 'body' });

    $.fn.modal.Constructor.prototype.enforceFocus = function() {}; // https://github.com/ivaynberg/select2/issues/1436
    $('#select2-team_users').select2();
    $("#select2-team_projects").select2({
      placeholder: "Select Project"
    });

    // Handle minimalize left menu
    $('.left-nav-toggle a').on('click', function(event){
        event.preventDefault();
        $("body").toggleClass("nav-toggle");
    });


    // Hide all open sub nav menu list
    $('.nav-second').on('show.bs.collapse', function () {
        $('.nav-second.in').collapse('hide');
    });


    // Handle panel close
    $('.panel-close').on('click', function(event){
        event.preventDefault();
        var hpanel = $(event.target).closest('div.panel');
        hpanel.remove();
    });
});
