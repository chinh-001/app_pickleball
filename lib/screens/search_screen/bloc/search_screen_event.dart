part of 'search_screen_bloc.dart';

abstract class SearchScreenEvent extends Equatable {
  const SearchScreenEvent();

  @override
  List<Object> get props => [];
}

class ClearSearch extends SearchScreenEvent {
  const ClearSearch();
}

class SearchCustomers extends SearchScreenEvent {
  final String query;
  final String channelToken;

  const SearchCustomers(this.query, {required this.channelToken});

  @override
  List<Object> get props => [query, channelToken];
}

class SearchItemsFound extends SearchScreenEvent {
  final List<dynamic> results;

  const SearchItemsFound(this.results);

  @override
  List<Object> get props => [results];
}

class ExecuteSearch extends SearchScreenEvent {
  final String query;
  final String channelToken;

  const ExecuteSearch({required this.query, required this.channelToken});

  @override
  List<Object> get props => [query, channelToken];
}

class SearchError extends SearchScreenEvent {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}
