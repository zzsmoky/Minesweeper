import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';

final class TodoDetailState extends Equatable {
  const TodoDetailState({this.todoItem});

  final TodoItem? todoItem;

  @override
  List<Object?> get props => [todoItem];
}

class TodoDetailCubit extends Cubit<TodoDetailState> {    // 1
  TodoDetailCubit({required TodoItem todo})
      : super(TodoDetailState(todoItem: todo));

  void setTodo(TodoItem todo) => emit(TodoDetailState(todoItem: todo));   // 2
}


@immutable
class TodoItem extends Equatable {
  final String title;
  final String description;

  const TodoItem({required this.title, required this.description});

  @override
  List<Object> get props => [title, description];
}
