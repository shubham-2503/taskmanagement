import 'package:get/get.dart';
import '../models/teams.dart';

class TeamsController extends GetxController {
  RxList<MyTeam> _teamsList = <MyTeam>[].obs;

  // Getter for the teams list
  List<MyTeam> get teamsList => _teamsList.toList();

  // Method to add a new team to the list
  void createTeam(MyTeam team) {
    _teamsList.add(team);
  }

  // Method to update an existing team in the list
  void updateTeam(MyTeam updatedTeam) {
    final index = _teamsList.indexWhere((team) => team.teamId == updatedTeam.teamId);
    if (index != -1) {
      _teamsList[index] = updatedTeam;
    }
  }

  // Method to delete a team from the list
  void deleteTeam(String teamId) {
    _teamsList.removeWhere((team) => team.teamId == teamId);
  }
}
