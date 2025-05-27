part of 'search_screen_bloc.dart';

abstract class SearchScreenState extends Equatable {
  const SearchScreenState();

  @override
  List<Object> get props => [];
}

class SearchScreenInitial extends SearchScreenState {}

class SearchLoading extends SearchScreenState {}

class SearchResults extends SearchScreenState {
  final List<dynamic> results;

  const SearchResults(this.results);

  @override
  List<Object> get props => [results];
}

class SearchErrorState extends SearchScreenState {
  final String message;

  const SearchErrorState(this.message);

  @override
  List<Object> get props => [message];
}
