import 'package:bloc/bloc.dart';


class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void onItemTapped(int index) => emit(index);
}
