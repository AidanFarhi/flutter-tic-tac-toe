const List<List<int>> winningLines = [
  [0, 1, 2], // top row
  [3, 4, 5], // middle row
  [6, 7, 8], // bottom row
  [0, 3, 6], // left column
  [1, 4, 7], // middle column
  [2, 5, 8], // bottom column
  [0, 4, 8], // diagonal
  [2, 4, 6], // anti-diagonal
];

String? findWinner(List<String> board) {
  for (final line in winningLines) {
    final first = board[line[0]];
    if (first != '' && first == board[line[1]] && first == board[line[2]]) {
      return first;
    }
  }
  return null;
}

bool isDraw(List<String> board) =>
    findWinner(board) == null && !board.contains('');

void main() {
  final empty = List.filled(9, '');
  print('empty -> winner: ${findWinner(empty)}, draw: ${isDraw(empty)}');

  final topRow = ['X', 'X', 'X', 'O', 'O', '', '', '', ''];
  print('topRow -> winner: ${findWinner(topRow)}, draw: ${isDraw(topRow)}');

  final diag = ['O', 'X', 'X', '', 'O', 'X', '', '', 'O'];
  print('diag -> winner: ${findWinner(diag)}, draw: ${isDraw(diag)}');

  final full = ['X', 'O', 'X', 'O', 'O', 'O', 'X', 'X'];
  print('full -> winner: ${findWinner(full)}, draw: ${isDraw(full)}');
}
