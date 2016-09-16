jQuery(function() {
  var cells, desired_width, table_width;
  if ($('#sortable').length > 0) {
    return $('#sortable').sortable({
      axis: 'y',
      items: '.item',
      cursor: 'move',
      sort: function(e, ui) {
        return ui.item.addClass('active-item-shadow');
      },
      stop: function(e, ui) {
        ui.item.removeClass('active-item-shadow');
        return ui.item.children('td').effect('highlight', {}, 1000);
      },
      update: function(e, ui) {
        var item_id, position;
        item_id = ui.item.data('item-id');
        position = ui.item.index();
        console.log(item_id, position);
        return $.ajax({
          type: 'PUT',
          url: '/backlogs/update_row_order',
          dataType: 'json',
          data: {
            backlog: {
              backlog_id: item_id,
              row_order: position
            }
          }
        });
      }
    });
  }
});

$(function() {
  $main = $('#main');
  $sidebar = $('#sidebar');

  $('tr.issue').click(function() {
    $main.removeClass('nosidebar');

    var id = $(this)[0].id.slice(6);
    console.info('Backlog issue.id=', id)
    $.ajax({
      type: 'GET',
      url: '/backlogs/' + id,
      dataType: 'html',
    }).done(function(response) {
      $sidebar.html(response);
    });
  });
  closeSidebar = function() {
    $sidebar.html('');
    $main.addClass('nosidebar')
  }
});
