part of 'favorites_bloc.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Playable> items;
  FavoritesLoaded({required this.items});
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError({required this.message});
}