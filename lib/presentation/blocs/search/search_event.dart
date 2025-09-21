part of 'search_bloc.dart';

abstract class SearchEvent {}

class PerformSearchEvent extends SearchEvent {
  final String query;
  PerformSearchEvent(this.query);
}

class ClearSearchEvent extends SearchEvent {}