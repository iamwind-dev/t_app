import 'package:equatable/equatable.dart';

class ThreadDraftItem extends Equatable {
  const ThreadDraftItem({required this.id, this.content = ''});

  final String id;
  final String content;

  ThreadDraftItem copyWith({String? id, String? content}) {
    return ThreadDraftItem(id: id ?? this.id, content: content ?? this.content);
  }

  @override
  List<Object?> get props => [id, content];
}

class ThreadDraft extends Equatable {
  const ThreadDraft({this.items = const []});

  final List<ThreadDraftItem> items;

  ThreadDraft copyWith({List<ThreadDraftItem>? items}) {
    return ThreadDraft(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
