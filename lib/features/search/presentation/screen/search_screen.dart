import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:t_app/features/search/presentation/cubit/search_users_cubit.dart';
import 'package:t_app/features/search/presentation/cubit/search_users_state.dart';
import 'package:t_app/features/users/data/user_profile.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

import '../theme/search_tokens.dart';
import '../widget/search_account_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.bottomPadding});

  final double bottomPadding;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _queryController;
  late final SearchUsersCubit _searchUsersCubit;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _searchUsersCubit = SearchUsersCubit(
      repository: context.read<UsersProfileRepository>(),
    );
  }

  @override
  void dispose() {
    _searchUsersCubit.close();
    _queryController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    _searchUsersCubit.searchByUsername(value);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SearchTokens.pageBackground(context),
      child: BlocBuilder<SearchUsersCubit, SearchUsersState>(
        bloc: _searchUsersCubit,
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.only(bottom: widget.bottomPadding),
            children: [
              _HeaderSection(
                controller: _queryController,
                isLoading: state.status == SearchUsersStatus.loading,
                onSubmitted: _submitSearch,
              ),
              const SizedBox(height: SearchTokens.listTopGap),
              ..._SearchResults(
                state: state,
                onFollowTap: _searchUsersCubit.toggleFollow,
              ).build(context),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.controller,
    required this.isLoading,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SearchTokens.horizontalPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SearchTokens.sectionVerticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tìm kiếm', style: SearchTokens.title(context)),
            const SizedBox(height: SearchTokens.titleToSearchGap),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SearchTokens.searchFieldHorizontalPadding,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: SearchTokens.searchFieldBackground(context),
                borderRadius: SearchTokens.searchBorderRadius,
              ),
              child: Row(
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      SearchTokens.searchIcon(context),
                      BlendMode.srcIn,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/search/search_magnifier.svg',
                      width: SearchTokens.searchIconSize,
                      height: SearchTokens.searchIconSize,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: SearchTokens.searchIconSize,
                          height: SearchTokens.searchIconSize,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: SearchTokens.searchIconGap),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: onSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm',
                        hintStyle: SearchTokens.searchHint(context),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: SearchTokens.searchHint(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults {
  const _SearchResults({required this.state, required this.onFollowTap});

  final SearchUsersState state;
  final VoidCallback onFollowTap;

  List<Widget> build(BuildContext context) {
    switch (state.status) {
      case SearchUsersStatus.loaded:
        final result = state.result;
        if (result == null) {
          return const [];
        }

        return [
          SearchAccountTile(
            item: _profileToSearchItem(result),
            onFollowTap: state.isUpdatingFollow ? null : onFollowTap,
          ),
        ];
      case SearchUsersStatus.failure:
        return [
          _SearchMessage(
            message: state.errorMessage ?? 'Không thể tìm kiếm người dùng.',
          ),
        ];
      case SearchUsersStatus.empty:
      case SearchUsersStatus.initial:
      case SearchUsersStatus.loading:
        return const [];
    }
  }

  SearchAccountItem _profileToSearchItem(UserProfile profile) {
    return SearchAccountItem(
      userId: profile.id,
      handle: profile.username,
      subtitle: profile.displayName,
      followers: '${profile.followersCount} người theo dõi',
      isFollowing: profile.isFollowing,
      avatarUrl: profile.avatarUrl,
      topPadding: SearchTokens.firstTileTopPadding,
      bottomPadding: SearchTokens.tileVerticalPadding,
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SearchTokens.horizontalPadding,
        vertical: 20,
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
