part of 'search_screen_bloc.dart';

abstract class SearchScreenEvent extends Equatable {
  const SearchScreenEvent();

  @override
  List<Object> get props => [];
}

class ClearSearch extends SearchScreenEvent {
  const ClearSearch();
}

class SearchItemsFound extends SearchScreenEvent {
  final List<String> results;

  const SearchItemsFound(this.results);

  @override
  List<Object> get props => [results];
}
