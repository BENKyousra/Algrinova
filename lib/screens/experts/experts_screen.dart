import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:algrinova/widgets/custom_bottom_navbar.dart';
import 'package:algrinova/screens/experts/experts_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertsScreen extends StatefulWidget {
  const ExpertsScreen({super.key});

  @override
  _ExpertsScreenState createState() => _ExpertsScreenState();
}

class Expert {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String imagePath;

  Expert({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.imagePath,
  });
}

class _ExpertsScreenState extends State<ExpertsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = '';
  double _selectedMinRating = 0;
  bool _sortDescending = true;
  bool _isSortActive = false;

  List<Expert> _experts = [];

  @override
  void initState() {
    super.initState();
    _loadExperts();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible) {
          setState(() {
            _isVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExperts() async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'expert') // Filtre sur le rôle expert
            .get();

    List<Expert> experts =
        querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Expert(
            id: doc.id,
            name: data['name'] ?? '',
            specialty: data['specialty'] ?? '',
            rating: (data['rating'] ?? 0).toDouble(),
            imagePath:
                data['photoUrl'] ??
                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
          );
        }).toList();

    setState(() {
      _experts = experts;
    });
  }

  Widget _buildExpertCard(Expert expert) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpertProfileScreen(expertId: expert.id),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  expert.imagePath,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 70,
                      width: 70,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 70);
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      expert.specialty,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < expert.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Contact de ${expert.name}")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Contact",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredExperts =
        _experts.where((expert) {
          final matchesSearch =
              expert.name.toLowerCase().contains(_searchQuery) ||
              expert.specialty.toLowerCase().contains(_searchQuery);
          final matchesSpecialty =
              _selectedSpecialty.isEmpty ||
              expert.specialty == _selectedSpecialty;
          final matchesRating = expert.rating >= _selectedMinRating;
          return matchesSearch && matchesSpecialty && matchesRating;
        }).toList();
    return GestureDetector(
      onTap: () {
        FocusScope.of(
          context,
        ).unfocus(); // Ferme le clavier et enlève le focus du champ
      },
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavBar(
          context: context,
          currentIndex: 1,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: _isVisible ? 155 : 0,
                  child: _buildCurvedHeader(),
                ),
                SizedBox(height: 5),
                Column(
                  children: [
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showFilterDialog,
                              icon: Icon(
                                Icons.filter_list,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Filter",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 0, 0, 0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _sortSpecialistsByRating,
                              icon: Icon(
                                color: Colors.white,
                                !_isSortActive
                                    ? Icons.sort
                                    : (_sortDescending
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward),
                              ),
                              label: Text(
                                "Sort",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 0, 0, 0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 10),
                    itemCount: filteredExperts.length,
                    itemBuilder: (context, index) {
                      final expert = filteredExperts[index];
                      return _buildExpertCard(expert);
                    },
                  ),
                ),
              ],
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: _isVisible ? 95 : -50,
              left: 20,
              right: 20,
              child: _buildSearchBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/blur.png"),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 25,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/icon.png', width: 28, height: 28),
              ),
              SizedBox(width: 5),
              Text(
                "Algrinova",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lobster',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 154,
          left: 0,
          right: 0,
          child: Container(
            height: 1.0,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 145, 145, 145),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 0.9,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 300,
      height: 45,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 143, 48),
            Color.fromARGB(255, 0, 41, 14),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showFilterDialog() {
    String tempSpecialty = _selectedSpecialty;
    double tempMinRating = _selectedMinRating;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Filter experts'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: tempSpecialty.isEmpty ? null : tempSpecialty,
                    hint: Text("Choose a specialty"),
                    items:
                        _experts
                            .map((e) => e.specialty)
                            .toSet()
                            .map(
                              (spec) => DropdownMenuItem(
                                value: spec,
                                child: Text(spec),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) =>
                            setModalState(() => tempSpecialty = value ?? ''),
                  ),
                  SizedBox(height: 20),
                  Text("Minimum rating : ${tempMinRating.toStringAsFixed(1)}"),
                  Slider(
                    value: tempMinRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: tempMinRating.toStringAsFixed(1),
                    onChanged:
                        (value) => setModalState(() => tempMinRating = value),
                    thumbColor: Color.fromARGB(255, 0, 143, 48),
                    activeColor: Color.fromARGB(255, 0, 143, 48),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Reset",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 143, 48),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedSpecialty = '';
                      _selectedMinRating = 0;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 52, 83),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedSpecialty = tempSpecialty;
                      _selectedMinRating = tempMinRating;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Apply",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _sortSpecialistsByRating() {
    setState(() {
      _isSortActive = true;
      _sortDescending = !_sortDescending;

      _experts.sort((a, b) {
        double ratingA = a.rating;
        double ratingB = b.rating;
        return _sortDescending
            ? ratingB.compareTo(ratingA)
            : ratingA.compareTo(ratingB);
      });
    });
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.9);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 1.05,
      size.width * 0.6,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
