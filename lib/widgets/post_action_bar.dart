import 'package:algrinova/screens/home/post_details_screen.dart';
import 'package:algrinova/services/dynamic_link_service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/post_service.dart'; // Assure-toi que le chemin est correct
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class PostActionBar extends StatefulWidget {
  final String ownerId;
  final String postId;
  final int initialLikes;
  final int comments;
  final int shares;
  final Set<String> likedBy; // IDs des utilisateurs qui ont liké
  final VoidCallback onCommentTap;
  final void Function(bool isLiked, int likeCount)? onLikeChanged;


  const PostActionBar({
    Key? key,
    required this.ownerId,
    required this.postId,
    required this.initialLikes,
    required this.comments,
    required this.shares,
    required this.likedBy,
    required this.onCommentTap,
     this.onLikeChanged,
  }) : super(key: key);

  @override
  State<PostActionBar> createState() => _PostActionBarState();
}

class _PostActionBarState extends State<PostActionBar> {
  late Set<String> _likes;
  bool _isLiked = false;
  final PostService _postService = PostService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? postData;


  @override
  void initState() {
    super.initState();
    handleDynamicLinks();
    _likes = Set<String>.from(widget.likedBy);
    _isLiked = _likes.contains(FirebaseAuth.instance.currentUser?.uid);
    _loadPost();
  }


void handleDynamicLinks() async {
  // Cas 1 : App lancée par un lien dynamique (cold start)
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink?.link != null) {
    _handleDeepLink(initialLink!.link);
  }

  // Cas 2 : App déjà ouverte, réception de lien dynamique (onLink stream)
  FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    _handleDeepLink(dynamicLinkData.link);
  }).onError((error) {
    print('Erreur de lien dynamique : $error');
  });
}


bool _isNavigating = false;

void _handleDeepLink(Uri? deepLink) async {
  if (deepLink != null && !_isNavigating) {
    _isNavigating = true;
    final uid = deepLink.queryParameters['uid'];
    final postId = deepLink.queryParameters['postId'];
    if (uid != null && postId != null) {
      final doc = await _firestore.collection('posts').doc(uid).collection('userPosts').doc(postId).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        await Navigator.push(context, MaterialPageRoute(
          builder: (context) => PostDetailScreen(
            ownerId: uid,
            postId: postId,
            name: data['name'] ?? '',
            location: data['location'] ?? '',
            hashtag: data['hashtag'] ?? '',
            caption: data['caption'] ?? '',
            image: data['imageUrl'] ?? '',
            likes: List<String>.from(data['likes'] ?? []),
            comments: data['comments'] ?? 0,
            shares: data['shares'] ?? 0,
            postOwnerUid: uid,
          ),
        ));
      }
    }
    _isNavigating = false;
  }
}


  Future<void> _loadPost() async {
    final doc =
        await _firestore.collection('posts')
        .doc(widget.ownerId)
        .collection('userPosts')
        .doc(widget.postId)
        .get();
    if (doc.exists) {
       if (!mounted) return;
      setState(() {
        postData = doc.data();
      });
      
    }
  }

  Future<void> _toggleLike() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await toggleLike(widget.ownerId, widget.postId, userId);
    if (!mounted) return;
    setState(() {
      if (_isLiked) {
        _likes.remove(userId);
      } else {
        _likes.add(userId);
      }
      _isLiked = !_isLiked;
      widget.onLikeChanged?.call(_isLiked, _likes.length);
    });
    
  }

  Future<void> toggleLike(String ownerId, String postId, String userId) async {
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId);

    final doc = await postRef.get();
    if (!doc.exists) return;

    final List<dynamic> likes = doc['likes'] ?? [];

    final likedPostRef = _firestore
        .collection('favorites')
        .doc(userId)
        .collection('likedPosts')
        .doc(postId);

    if (likes.contains(userId)) {
      // Supprimer le like
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      // Ajouter le like
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }

     final postData = doc.data();
      if (postData != null) {
        await likedPostRef.set({
          'ownerId': ownerId,
          'caption': postData['caption'] ?? '',
          'hashtag': postData['hashtag'] ?? '',
          'imageUrl': postData['imageUrl'] ?? '',
          'likes': postData['likes'] ?? [],
          'timestamp': Timestamp.now(),
          'comments': postData['comments'] ?? 0,
          'shares': postData['shares'] ?? 0,
          'userId': userId,
          'location': postData['location'] ?? '',
          'photoUrl': postData['photoUrl'] ?? '',
          'name': postData['name'] ?? '',
          'postId': postId,
          'likedAt': FieldValue.serverTimestamp(),
        });
      }
  }
void sharePost(String uid, String postId) async {
  final link = await DynamicLinkService.createDynamicLink(uid: uid, postId: postId);
  Share.share("🌿 Viens voir ce post sur Algrinova ! $link");
}

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Like
        InkWell(
          onTap: _toggleLike,
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color:
                    _isLiked
                        ? Color.fromARGB(255, 255, 47, 92)
                        : Color.fromRGBO(80, 80, 80, 1),
              ),
              SizedBox(width: 5),
              Text(_likes.length.toString()),
            ],
          ),
        ),

        // Commentaire
        InkWell(
          onTap: widget.onCommentTap,
          child: Row(
            children: [
              Icon(
                Icons.mode_comment_rounded,
                color: Color.fromRGBO(80, 80, 80, 1),
              ),
              SizedBox(width: 5),
              Text(widget.comments.toString()),
            ],
          ),
        ),

        // Share (non fonctionnel ici)
        InkWell(
          onTap: () => sharePost(widget.ownerId, widget.postId),

          child: Row(
            children: [
              Icon(Icons.share, color: Color.fromRGBO(80, 80, 80, 1)),
              SizedBox(width: 5),
              Text(widget.shares.toString()),
            ],
          ),
        ),
      ],
    );
  }
}
