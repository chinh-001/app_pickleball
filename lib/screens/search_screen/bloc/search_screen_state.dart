part of 'search_screen_bloc.dart';

abstract class SearchScreenState extends Equatable {
  const SearchScreenState();

  @override
  List<Object> get props => [];
}

class SearchScreenInitial extends SearchScreenState {}

class SearchLoading extends SearchScreenState {}

class SearchResults extends SearchScreenState {
  final List<String> results;

  const SearchResults(this.results);

  @override
  List<Object> get props => [results];
}
