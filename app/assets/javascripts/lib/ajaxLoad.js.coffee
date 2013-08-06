board_path = (id) -> "/ajax/board/#{id}"

window.reloadBoard = (id) ->
  boards = $("li.board.board_#{id}")
  if boards.length
    $.get board_path(id), (html) ->
      boards.replaceWith( $(html) )