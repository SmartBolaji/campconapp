import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class SearchInputScreen extends StatefulWidget {
  const SearchInputScreen({super.key});

  @override
  State<SearchInputScreen> createState() => _SearchInputScreenState();
}

class _SearchInputScreenState extends State<SearchInputScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> previousSearches = [
    'Music',
    'Champions League',
    'Flutter 3.0'
  ];
  final List<String> trendingSearches = [
    'Coldplay Tour',
    'AI in Tech',
    'Elections 2024',
    'TechCrunch',
    'Met Gala Highlights',
  ];

  @override
  void initState() {
    super.initState();
    // Automatically focus the search input when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          focusNode: FocusNode(),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle:
                TextStyle(fontFamily: 'Trebuchet', color: Colors.grey.shade600),
            border: InputBorder.none,
            // prefixIcon: Icon(IconlyLight.search, color: Colors.blue),
            filled: true,
            fillColor: Colors.white,

            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    // style: ButtonStyle(
                    //     backgroundColor:
                    //         WidgetStatePropertyAll(Colors.grey.shade200)),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear(); // Clears the text field
                      setState(() {}); // Redraws the widget
                    },
                  )
                : null, // Show the clear button only when there is text
          ),
          onChanged: (value) {
            // Handle search input
          },
          onSubmitted: (value) {
            if (value.isNotEmpty && !previousSearches.contains(value)) {
              setState(() {
                previousSearches.insert(0, value); // Add new search to history
              });
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Previously Searched
          if (previousSearches.isNotEmpty)
            _buildSectionTitle('Previously Searched'),
          if (previousSearches.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  previousSearches.map((item) => _buildChip(item)).toList(),
            ),
          const SizedBox(height: 20),

          // Section: Trending Searches
          _buildSectionTitle('Trending Searches'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: trendingSearches.map((item) => _buildChip(item)).toList(),
          ),
        ],
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontFamily: 'Trebuchet', // Add Trebuchet font family
        ),
      ),
    );
  }

  // Chip Widget with Delete Icon
  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blue.shade50,
      labelStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.w600,
        fontFamily: 'Trebuchet', // Use Trebuchet font family here too
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      deleteIcon: const Icon(Icons.cancel, color: Colors.blue),
      deleteIconColor: Colors.blue, // Set delete icon color
      onDeleted: () {
        setState(() {
          previousSearches.remove(label); // Remove the chip from the list
        });
      },
    );
  }
}
