import 'package:chess_game/components/dead_piece.dart';
import 'package:chess_game/components/piece.dart';
import 'package:chess_game/components/square.dart';
import 'package:chess_game/helper/helper_func.dart';
import 'package:chess_game/values/colors.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //2D list representing chess board
  //with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  //currently selected piece on board
  //if no selected this is null
  ChessPiece? selectedPiece;

  //Rown & Col of selected Piece
  int selectedRow = -1;
  int selectedCol = -1;

  //valid moves for currently selected piece
  List<List<int>> validMoves = [];

  //List of White Pieces taken by Black
  List<ChessPiece> whitePiecesTaken = [];

  //List of Black Pieces taken by White
  List<ChessPiece> blackPiecesTaken = [];

  //A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  //Position of Kings
  List<int> whiteKingPosition = [7,4];
  List<int> blackKingPosition = [0,4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //Initialize Board
  void _initializeBoard() {
    //initiakize board with nulls, no pieces at begining
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          Type: chessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn_black.png');

      newBoard[6][i] = ChessPiece(
          Type: chessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn_black.png');
    }

    //place rooks
    newBoard[0][0] = ChessPiece(
        Type: chessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook_black.png');
    newBoard[0][7] = ChessPiece(
        Type: chessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook_black.png');
    newBoard[7][0] = ChessPiece(
        Type: chessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook_black.png');
    newBoard[7][7] = ChessPiece(
        Type: chessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook_black.png');

    //place knights
    newBoard[0][1] = ChessPiece(
        Type: chessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight_black.png');
    newBoard[0][6] = ChessPiece(
        Type: chessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight_black.png');
    newBoard[7][1] = ChessPiece(
        Type: chessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight_black.png');
    newBoard[7][6] = ChessPiece(
        Type: chessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight_black.png');

    //place bishops
    newBoard[0][2] = ChessPiece(
        Type: chessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop_black.png');
    newBoard[0][5] = ChessPiece(
        Type: chessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop_black.png');
    newBoard[7][2] = ChessPiece(
        Type: chessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop_black.png');
    newBoard[7][5] = ChessPiece(
        Type: chessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop_black.png');

    //place queens
    newBoard[0][3] = ChessPiece(
        Type: chessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen_black.png');
    newBoard[7][3] = ChessPiece(
        Type: chessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen_black.png');
    //place kings
    newBoard[0][4] = ChessPiece(
        Type: chessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king_black.png');
    newBoard[7][4] = ChessPiece(
        Type: chessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king_black.png');
    board = newBoard;
  }

  //user selected a piece
  void pieceSelected(int row, int col) {
    setState(() {
      //No piece has been selected yet and this is first selection
      if (selectedPiece == null && board[row][col] != null) {
        if(board[row][col]!.isWhite==isWhiteTurn){
          selectedPiece = board[row][col];
          selectedCol = col;
          selectedRow = row;
        }
      }
      //there is a peiece already selected but user can select one of their other pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedCol = col;
        selectedRow = row;
      }
      //if there is piece selected and user taps on another square and that is a valid move then we can move there
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      validMoves =
          calculateRealValidMoves(selectedRow, selectedCol, selectedPiece,true);
      //After a piece is selected, calculate its valid moves
    });
  }

  //Raw Valid Moves
  List<List<int>> calculateRawValidMoves(int row, col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.Type) {
      case chessPieceType.pawn:
        //pawns can move forward if square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        //pawns can move 2 position forward if they are at initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        //pawns can capture upto 1 position diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case chessPieceType.rook:
        //horizontal and vertical moves
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1] //right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //kill
              }
              break; //blocked further
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case chessPieceType.knight:
        //all eight possible eight shaped moves
        var knightMoves = [
          [-2, -1], //up 2, left 1
          [-2, 1], //up 2, right 1
          [-1, -2], //up 1, left 2
          [-1, 2], //up 1, right 2
          [1, -2], //down 1, left 2
          [1, 2], //down 1, right 2
          [2, -1], //down 2, left 1
          [2, 1], //down 2, right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case chessPieceType.bishop:
        //diagonalmoves
        var directions = [
          [-1, -1], //up-left
          [-1, 1], //up-right
          [1, -1], //down-left
          [1, 1] //down-right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //kill
              }
              break; //blocked further
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case chessPieceType.queen:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up-left
          [-1, 1], //up-right
          [1, -1], //down-left
          [1, 1] //down-right
        ];
        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //kill
              }
              break; //blocked further
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case chessPieceType.king:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up-left
          [-1, 1], //up-right
          [1, -1], //down-left
          [1, 1] //down-right
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //kill
            }
            continue; //blocked further
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;

      default:
    }

    return candidateMoves;
  }

  //Real Valid Moves
  List<List<int>> calculateRealValidMoves(int row, col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // after generating all possible moves, check if any of that would result in check to king
    if(checkSimulation){
      for(var move in candidateMoves){
        int endRow = move[0];
        int endCol = move[1];

        //this will simulate future move if it is safe
        if(simulatedMoveIsSafe(piece!,row,col,endRow,endCol)){
          realValidMoves.add(move);
        }
      }
    }
    else{
      realValidMoves = candidateMoves;
    }

    return realValidMoves;

  }
  //Move the Piece
  void movePiece(int newRow, newCol) {
    //if the new spot has a enemy piece
    if (board[newRow][newCol] != null) {
      //add the captured piece to appropriate list
      var capturedPiece = board[newRow][newCol];

      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    if(selectedPiece!.Type==chessPieceType.king){
      if(selectedPiece!.isWhite){
        whiteKingPosition = [newRow, newCol];
      }
      else{
        blackKingPosition = [newRow, newCol];
      }
    }

    //Move the Piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //see if anyking under attack
    if(isKingInCheck(!isWhiteTurn)){
      checkStatus=true;
    }
    else{
      checkStatus=false;
    }



    //Check if it's checkmate
    if(isCheckMate(!isWhiteTurn)){
      showDialog(context: context, builder: (context)=>AlertDialog(
        title: Text('Check Mate!!!'),
        actions: [
          TextButton(onPressed: resetGame, child: Text('Play Again'))
        ],
      ));
    }
    //claer the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
    //change turns
    isWhiteTurn=!isWhiteTurn;
  }

  //is King in Check
  bool isKingInCheck(bool isWhiteKing){
    //get position of King
    List<int> kingPosition = isWhiteKing?whiteKingPosition:blackKingPosition;

    //check if any enemy piece can attack the king
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        //skip empty square and pieces same color as of king
        if(board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j],false);

        //check kings position is in any of this valid moves
        if(pieceValidMoves.any((move)=> move[0]==kingPosition[0] && move[1]==kingPosition[1])){
          return true;
        }


      }
    }
    return false;

  }

  //simulate future move if safe (doesn't put our king under attack)
  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol){
    //save the current board state coz we will return back if it's not safe
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    //if piece is king save its current position and update to new one
    List<int>? originalKingPosition;
    if(piece.Type == chessPieceType.king){
      originalKingPosition = piece.isWhite? whiteKingPosition : blackKingPosition;

      if(piece.isWhite){
        whiteKingPosition = [endRow,endCol];
      }
      else{
        blackKingPosition = [endRow,endCol];
      }
    }
    //simulate the move
    board[endRow][endCol]= piece;
    board[startRow][startCol]=null;

    //chech if king under attack after simulated move
    bool kingInCheck = isKingInCheck(piece.isWhite);

    //restore board to original position
    board[startRow][startCol]=piece;
    board[endRow][endCol]= originalDestinationPiece;

    //if it's king, restore it to original position
    if(piece.Type == chessPieceType.king){
      if(piece.isWhite){
        whiteKingPosition = originalKingPosition!;
      }
      else{
        blackKingPosition = originalKingPosition!;
      }
    }
    //if king in check, the move is not safe
    return !kingInCheck;


  }

  //is it checkmate
  bool isCheckMate(bool isWhiteKing){
    //if king is not in check, it's not checkMate
    if(!isKingInCheck(isWhiteKing)){
      return false;
    }
    
    //if there is atleast one legal move possible for any piece of that player it's not checkmate
    for(int i=0; i<8; i++){
      for(int j=0; j<8; j++){
        //skip empty and opposite pieces
        if(board[i][j]==null || board[i][j]!.isWhite != isWhiteKing){
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j],true);

        if(pieceValidMoves.isNotEmpty){
          return false;
        }
      }
    }
    //if none of the condition above are met, it's CheckMate
    return true;  
  }

  //Reset to new game
  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    blackPiecesTaken.clear();
    whitePiecesTaken.clear();
    isWhiteTurn = true;  
    whiteKingPosition = [7,4];
    blackKingPosition = [0,4];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          //White Pieces Taken
          Expanded(
              child: GridView.builder(
                itemCount: whitePiecesTaken.length,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                 itemBuilder: (context, index) => DeadPiece(imagePath: whitePiecesTaken[index].imagePath, isWhite: true)
              )
          
          ),

          Text(checkStatus?"Check!!":"No"),
          
          //Chess Board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;

                //check is square is selected
                bool isSelected = selectedRow == row && selectedCol == col;

                //check if square is validMove
                bool isValidMove = false;
                for (var position in validMoves) {
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),

          //Black Pieces Taken
          Expanded(
              child: GridView.builder(
                itemCount: blackPiecesTaken.length,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                 itemBuilder: (context, index) => DeadPiece(imagePath: blackPiecesTaken[index].imagePath, isWhite: false)
              )
          
          ),
        ],
      ),
    );
  }
}
