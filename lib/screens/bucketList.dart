import 'package:flutter/material.dart';
import '../widgets/tabBar.dart';
import 'postDetailPage.dart'; // Import PostDetailPage

class BucketList extends StatefulWidget {
  final String userId;

  const BucketList({Key? key, required this.userId}) : super(key: key);

  @override
  _BucketListState createState() => _BucketListState();
}

class _BucketListState extends State<BucketList> {
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Coffee Shops',
    'Restaurants',
    'Adventure',
    'Activity',
    'Bars',
  ];

  // Mock data for bucket list with descriptions
  final List<Map<String, String>> bucketListItems = [
    {
      'category': 'Coffee Shops',
      'title': 'Starbucks Downtown',
      'username': 'JohnDoe',
      'image': 'images/coffee.jpg',
      'description': 'Best coffee in town, must try their Caramel Macchiato!'
    },
    {
      'category': 'Adventure',
      'title': 'Skydiving Miami',
      'username': 'AdventureGirl',
      'image': 'images/skydiving.jpg',
      'description': 'Once in a lifetime experience. Thrilling and fun!'
    },
    {
      'category': 'Bars',
      'title': 'The Blue Bar',
      'username': 'NightOwl99',
      'image': 'images/bar.jpg',
      'description': 'Chill vibes and great cocktails!'
    },
    {
      'category': 'Restaurants',
      'title': 'Olive Garden Dinner',
      'username': 'FoodieMike',
      'image': 'images/restaurant.jpg',
      'description': 'Amazing pasta and cozy atmosphere.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter items based on selected category
    List<Map<String, String>> filteredItems = selectedCategory == 'All'
        ? bucketListItems
        : bucketListItems
            .where((item) => item['category'] == selectedCategory)
            .toList();

    return Scaffold(
      body: Column(
        children: [
          //Custom tab bar
          CustomTabBar(currentTab: "Bucket List", currentUserId: widget.userId),

          //Dropdown filter
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Category: ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    isExpanded: true,
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          //List of filtered items
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return BucketListItem(
                    title: item['title']!,
                    username: item['username']!,
                    imagePath: item['image']!,
                    description: item['description']!,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Reusable bucket list item with tap to detail
class BucketListItem extends StatelessWidget {
  final String title;
  final String username;
  final String imagePath;
  final String description;

  const BucketListItem({
    Key? key,
    required this.title,
    required this.username,
    required this.imagePath,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.location_pin, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('@$title posted by $username',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      //Navigate to post detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(
                            title: title,
                            username: username,
                            imagePath: imagePath,
                            description: description,
                          ),
                        ),
                      );
                    },
                    child: Text('See The Now',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
