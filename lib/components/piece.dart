enum chessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  final chessPieceType Type;
  final bool isWhite;
  final String imagePath;

  ChessPiece(
      {
        required this.Type, 
        required this.isWhite, 
        required this.imagePath});
}
