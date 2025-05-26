import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_screen_event.dart';
part 'search_screen_state.dart';

class SearchScreenBloc extends Bloc<SearchScreenEvent, SearchScreenState> {
  SearchScreenBloc() : super(SearchScreenInitial());

  @override
  Stream<SearchScreenState> mapEventToState(SearchScreenEvent event) async* {
    // TODO: implement mapEventToState
  }
}
