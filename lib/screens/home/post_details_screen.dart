import 'dart:io';
import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final String profileImage;
  final String username;
  final String location;
  final String hashtag;
  final String caption;
  final String image;
  final int likes;
  final int comments;
  final int shares;
  final bool scrollToComment;

  PostDetailScreen({
    required this.profileImage,
    required this.username,
    required this.location,
    required this.hashtag,
    required this.caption,
    required this.image,
    required this.likes,
    required this.comments,
    required this.shares,
    this.scrollToComment = false,
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, String>> commentList;

  @override
  void initState() {
    super.initState();
    // Exemple de commentaires initiaux
    commentList = [
      {
        'profileImage': 'assets/images/pexels-mlkbnl-10251392.jpg',
        'username': 'Fatima93',
        'date': '12/04/2025 14:22',
        'text': 'Magnifique post, bravo 👏',
      },
      {
        'profileImage': 'assets/images/blur.png',
        'username': 'ZakiDZ',
        'date': '12/04/2025 15:03',
        'text': 'Ça pousse bien, super résultat ! 🌱',
      },
    ];
    if (widget.scrollToComment) {
      // attendre la fin du premier frame puis scroller en bas
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    final now = DateTime.now();
    final date =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year} ${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";

    setState(() {
      commentList.add({
        'profileImage': widget.profileImage,
        'username': widget.username,
        'date': date,
        'text': _commentController.text.trim(),
      });
      _commentController.clear();
      // scroller en bas
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          child: AppBar(
            title: Text(
              'Post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: Image.asset(
              'assets/images/blur.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header du post
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: _imageProvider(widget.profileImage),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            widget.location,
                            style: TextStyle(color: Color.fromARGB(255, 0, 143, 48),fontWeight: FontWeight.bold,fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "${widget.hashtag} ",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: widget.caption),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Image du post
                  if (widget.image.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image(
                        image: _imageProvider(widget.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 10),
                  // Bar d'actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            Icon(Icons.favorite, color: Color.fromRGBO(80, 80, 80, 1)),
                            SizedBox(width: 5),
                            Text(widget.likes.toString()),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _addComment,
                        child: Row(
                          children: [
                            Icon(
                              Icons.mode_comment_rounded,
                              color:Color.fromRGBO(80, 80, 80, 1),
                            ),
                            SizedBox(width: 5),
                            Text(widget.comments.toString()),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            Icon(Icons.share, color: Color.fromRGBO(80, 80, 80, 1)),
                            SizedBox(width: 5),
                            Text(widget.shares.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(thickness: 0.8, color: Colors.grey[300]),
                  SizedBox(height: 5),
                  Text(
                    "Commentaires",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 143, 48),
                    ),
                  ),
                  SizedBox(height: 5),
                  ...commentList.map((comment) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: _imageProvider(
                              comment['profileImage']!,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment['username']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      comment['date']!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  comment['text']!,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          // Champ commentaire
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 217, 217),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Ajouter un commentaire...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Color.fromRGBO(80, 80, 80, 1),
                    ),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
