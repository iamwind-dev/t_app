import 'models/thread_item_model.dart';

class ThreadTreeUpdater {
  const ThreadTreeUpdater._();

  static ThreadItemModel attachChildren({
    required ThreadItemModel root,
    required String parentId,
    required List<ThreadItemModel> children,
  }) {
    if (root.id == parentId) {
      return root.copyWith(children: children);
    }

    if (root.children.isEmpty) {
      return root;
    }

    return root.copyWith(
      children: root.children
          .map(
            (child) => attachChildren(
              root: child,
              parentId: parentId,
              children: children,
            ),
          )
          .toList(growable: false),
    );
  }
}
