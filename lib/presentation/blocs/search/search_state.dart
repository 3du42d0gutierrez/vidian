part of 'search_bloc.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Playable> results;
  SearchLoaded({required this.results});
}

class SearchError extends SearchState {
  final String message;
  SearchError({required this.message});
}