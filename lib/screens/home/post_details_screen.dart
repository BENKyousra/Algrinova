import 'package:algrinova/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algrinova/services/post_service.dart';
import 'package:algrinova/services/user_service.dart';


class PostDetailScreen extends StatefulWidget {
  final String name;
  final String location;
  final String hashtag;
  final String caption;
  final String image;
  final int likes;
  final int comments;
  final int shares;
  final bool scrollToComment;
  final String postId;
  final String postOwnerUid;

  const PostDetailScreen({
    required this.name,
    required this.location,
    required this.hashtag,
    required this.caption,
    required this.image,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.postId,
    required this.postOwnerUid,
    this.scrollToComment = false,
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  String? caption;
String? hashtag;
bool isLoadingPostData = true;
 String? _currentPhotoUrl;


  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> commentList;

  Future<void> _loadComments() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('posts')
      .doc(widget.postOwnerUid)
      .collection('userPosts')
      .doc(widget.postId)
      .collection('comments')
      .orderBy('timestamp', descending: true)
      .get();

  List<Map<String, dynamic>> loadedComments = [];
  for (var doc in snapshot.docs) {
    final data = doc.data();
    String userId = data['userId'] ?? '';
    String photoUrl = '';
    if (userId.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      photoUrl = userDoc.data()?['photoUrl'] ?? '';
    }
    loadedComments.add({
      'photoUrl': photoUrl,
      'name': data['name'] ?? 'Inconnu',
      'date': data['timestamp'] != null
          ? _formatTimestamp(data['timestamp'])
          : '',
      'text': data['text'] ?? '',
    });
  }
  setState(() {
    commentList = loadedComments;
  });
}

String _formatTimestamp(Timestamp timestamp) {
  final date = timestamp.toDate();
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year} ${date.hour.toString().padLeft(2, '0')}:"
      "${date.minute.toString().padLeft(2, '0')}";
}
@override
void initState() {
  super.initState();
   _fetchUserPhotoUrl().then((_) {
    setState(() {
      isLoadingPostData = false;
    });
  });
  commentList = [];

  _loadPostData(); // Nouvelle fonction
  _loadComments();
  

  if (widget.scrollToComment) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}

void _loadPostData() async {
  final doc = await FirebaseFirestore.instance
      .collection('posts')
      .doc(widget.postOwnerUid)
      .collection('userPosts')
      .doc(widget.postId)
      .get();

  if (doc.exists) {
    setState(() {
      caption = doc['caption'];
      hashtag = doc['hashtag'];
      isLoadingPostData = false;
    });
  }
}

Future<void> _fetchUserPhotoUrl() async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.postOwnerUid)
      .get();

  if (doc.exists) {
    setState(() {
      _currentPhotoUrl = doc['photoUrl'];
    });
  }
}

  void _addComment() async {
  if (_commentController.text.trim().isEmpty) return;

  final now = DateTime.now();
  final date = "${now.day.toString().padLeft(2, '0')}/"
      "${now.month.toString().padLeft(2, '0')}/"
      "${now.year} ${now.hour.toString().padLeft(2, '0')}:" 
      "${now.minute.toString().padLeft(2, '0')}";

  final text = _commentController.text.trim();

  // 🔹 Récupérer l’utilisateur connecté
  final currentUserInfo = await UserService().getCurrentUserInfo();
  final name = currentUserInfo['name'];
  final photoUrl = currentUserInfo['photoUrl'];
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonyme';

  // 🔹 Affichage visuel
  setState(() {
    commentList.add({
      'photoUrl': photoUrl,
      'name': name,
      'date': date,
      'text': text,
    });
    _commentController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  });

  // 🔥 Enregistrement dans Firestore
  await PostService().addComment(
    ownerId: widget.postOwnerUid,
    postId: widget.postId,
    userId: userId,
    name: name,
    text: text,
    photoUrl: photoUrl,
  );
}

 
  ImageProvider _imageProvider(String photoUrl) {
  if (photoUrl.isNotEmpty) {
    return NetworkImage(photoUrl);
  } else {
    return AssetImage('assets/default_profile.png');
  }
}

void _confirmDeletePost() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer le post'),
      content: Text('Es-tu sûr de vouloir supprimer ce post ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postOwnerUid)
        .collection('userPosts')
        .doc(widget.postId)
        .delete();
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(widget.postId)
        .delete();

    Navigator.pop(context); // Retour à l'écran précédent
  }
}

void _showEditDialog() {
  TextEditingController captionController =
      TextEditingController(text: caption);
  TextEditingController hashtagController =
      TextEditingController(text: hashtag);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Modifier le post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: captionController,
            decoration: InputDecoration(labelText: 'Caption'),
          ),
          TextField(
            controller: hashtagController,
            decoration: InputDecoration(labelText: 'Hashtag'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black // Couleur verte
          ),
          onPressed: () async {
            final newCaption = captionController.text.trim();
            final newHashtag = hashtagController.text.trim();

            await FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postOwnerUid)
                .collection('userPosts')
                .doc(widget.postId)
                .update({
              'caption': newCaption,
              'hashtag': newHashtag,
            });

            setState(() {
              caption = newCaption;
              hashtag = newHashtag;
            });

            Navigator.of(context).pop();
          },
          child: Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    if (isLoadingPostData) {
    return Scaffold(
      appBar: AppBar(title: Text('Chargement...')),
      body: Center(child: CircularProgressIndicator()),
    );
  }
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
      actions: [
  if (FirebaseAuth.instance.currentUser?.uid == widget.postOwnerUid)
    PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          _showEditDialog();
        } else if (value == 'delete') {
          _confirmDeletePost();
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'edit',
            child: Text('Modifier'),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Text('Supprimer'),
          ),
        ];
      },
    ),
],

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
                        backgroundImage:  _currentPhotoUrl != null
      ? NetworkImage(_currentPhotoUrl!)
      : AssetImage('assets/images/default.png') as ImageProvider,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
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
  onTap: () async {
    final ownerId = widget.postOwnerUid;
    final postId = widget.postId;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return; // Prevent calling with null userId
    await PostService().toggleLike(ownerId, postId, userId);
    setState(() {}); // force la reconstruction si nécessaire
  },

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
                              comment['photoUrl']!,
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
                                      comment['name']!,
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
