part of 'favorites_bloc.dart';

abstract class FavoritesEvent {}

class LoadFavoritesEvent extends FavoritesEvent {}

class AddFavoriteEvent extends FavoritesEvent {
  final Playable item;
  AddFavoriteEvent(this.item);
}

class RemoveFavoriteEvent extends FavoritesEvent {
  final Playable item;
  RemoveFavoriteEvent(this.item);
}