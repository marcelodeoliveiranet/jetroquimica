import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<SingleChildWidget>> getDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  return [
    Provider<SharedPreferences>.value(value: sharedPreferences),

    ///Services
    ///Repositories
    ///ViewModel
  ];
}
