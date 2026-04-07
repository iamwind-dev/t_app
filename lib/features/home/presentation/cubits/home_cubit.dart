import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/post_detail/data/mock_thread_repository.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({MockThreadRepository repository = const MockThreadRepository()})
    : _repository = repository,
      super(const HomeState()) {
    loadHomeFeed();
  }

  final MockThreadRepository _repository;

  void loadHomeFeed() {
    emit(state.copyWith(rootThreads: _repository.fetchRootThreads()));
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }
}
