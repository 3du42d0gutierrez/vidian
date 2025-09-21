part of 'catalog_bloc.dart';

abstract class CatalogState {}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<Playable> items;
  final bool hasReachedMax;
  final int page;

  CatalogLoaded({required this.items, this.hasReachedMax = false, this.page = 1});
}

class CatalogError extends CatalogState {
  final String message;
  CatalogError({required this.message});
}

class CatalogEmpty extends CatalogState {}