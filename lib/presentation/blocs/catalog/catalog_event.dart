part of 'catalog_bloc.dart';

abstract class CatalogEvent {}

class LoadCatalogEvent extends CatalogEvent {
  final int page;
  final int pageSize;
  final String? query;
  final bool forceRefresh;

  LoadCatalogEvent({this.page = 1, this.pageSize = 20, this.query, this.forceRefresh = false});
}

class LoadMoreCatalogEvent extends CatalogEvent {
  final String? query;
  final int pageSize;

  LoadMoreCatalogEvent({this.pageSize = 20, this.query});
}

class RefreshCatalogEvent extends CatalogEvent {}

class SearchCatalogEvent extends CatalogEvent {
  final String query;
  SearchCatalogEvent(this.query);
}

class ToggleFavoriteEvent extends CatalogEvent {
  final String contentId;
  ToggleFavoriteEvent(this.contentId);
}