import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/search_screen/bloc/search_screen_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/input/custom_search_text_field.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({Key? key, this.initialQuery = ''}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final SearchScreenBloc _bloc;

  // Demo suggestions list (for display purposes)
  final List<String> _demoSuggestions = [
    'xịt khoá makeup',
    'xịt khoáng makeup',
    'xịt buổi mọc tóc',
    'xịt giữ nếp tóc',
    'xịt khử mùi',
    'xịt khoá makeup 3ce',
    'xịt thơm miệng',
    'xịt muỗi cho bé',
    'xịt thơm quần áo',
    'xịt mọc tóc',
    'xịt khoáng dưỡng ẩm',
    'xịt khử mùi giày',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = SearchScreenBloc();
    _searchController.text = widget.initialQuery;

    // Add listener để cập nhật UI khi text thay đổi
    _searchController.addListener(() {
      setState(() {}); // Cập nhật UI để hiển thị/ẩn icon clear
    });

    // Simulate search based on initial query
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }

  void _performSearch(String query) {
    // Filter suggestions based on query
    if (query.isEmpty) {
      _bloc.add(const ClearSearch());
    } else {
      final results =
          _demoSuggestions
              .where(
                (suggestion) =>
                    suggestion.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
      _bloc.add(SearchItemsFound(results));
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      setState(() {});
    });
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocBuilder<SearchScreenBloc, SearchScreenState>(
        builder: (context, state) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: AppBar(
                backgroundColor: Colors.green,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            ).translate('searchCustomer'),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          onChanged: _performSearch,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _performSearch('');
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                actions: const [],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child:
                      state is SearchResults && state.results.isNotEmpty
                          ? _buildSearchResults(state.results)
                          : state is SearchLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildEmptyState(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(List<String> results) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          title: Text(results[index], style: const TextStyle(fontSize: 16)),
          onTap: () {
            // Return the selected item to previous screen
            Navigator.pop(context, results[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isEmpty) {
      // Danh sách gợi ý mặc định
      return ListView.separated(
        itemCount: _demoSuggestions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: Text(
              _demoSuggestions[index],
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context, _demoSuggestions[index]);
            },
          );
        },
      );
    } else {
      // Không có kết quả tìm kiếm
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('noResultsFound'),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
  }
}
