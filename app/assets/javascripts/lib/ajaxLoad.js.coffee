board_path = (id) -> "/ajax/board/#{id}"

window.reloadBoard = (id) ->
  boards = $("li.board.board_#{id}")
  if boards.length
    $.get board_path(id), (html) ->
      # Only replace contents, not whole LI, to avoid messing with masonry layouts
      boards.wrapInner('<div class="innerWrapper">')
      boards.find('.innerWrapper').replaceWith $(html).contents()
