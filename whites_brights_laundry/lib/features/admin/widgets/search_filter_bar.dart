import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class SearchFilterBar extends StatelessWidget {
  final String? searchTerm;
  final Map<String, String>? filters;
  final VoidCallback onClear;

  const SearchFilterBar({
    Key? key,
    this.searchTerm,
    this.filters,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: GlobalColors.primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          const Text(
            'Filters:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (searchTerm != null)
                  Chip(
                    label: Text('Search: $searchTerm'),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: GlobalColors.primaryColor),
                    ),
                  ),
                if (filters != null)
                  ...filters!.entries.map(
                    (entry) => Chip(
                      label: Text('${entry.key}: ${entry.value}'),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: GlobalColors.primaryColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: onClear,
            tooltip: 'Clear filters',
          ),
        ],
      ),
    );
  }
}
