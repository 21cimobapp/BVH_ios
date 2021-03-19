import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:civideoconnectapp/theme_selector.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
//import 'languages_screen.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Common',
            tiles: [
              SettingsTile.switchTile(
                title: 'Online',
                enabled: globals.loginUserType == "DOCTOR" ? true : false,
                leading: Icon(Icons.work),
                switchValue: globals.isOnline,
                onToggle: (value) {
                  setState(() {
                    globals.isOnline = value;
                  });
                  DatabaseMethods()
                      .updateDoctorOnlineStatus(globals.personCode, value);
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Security',
            tiles: [
              SettingsTile.switchTile(
                title: 'Enable Notification',
                enabled: notificationsEnabled,
                leading: Icon(Icons.notifications),
                switchValue: true,
                onToggle: (value) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Misc',
            tiles: [
              // SettingsTile(
              //   title: 'Theme',
              //   subtitle: 'Theme Selection',
              //   leading: Icon(Icons.colorize),
              //   onTap: () {
              //     Navigator.of(context).push(MaterialPageRoute(
              //         builder: (BuildContext context) => ThemeSelector()));
              //   },
              // ),
              SettingsTile(
                  title: 'Terms of Service', leading: Icon(Icons.description)),
              SettingsTile(
                  title: 'Open source licenses',
                  leading: Icon(Icons.collections_bookmark)),
            ],
          )
        ],
      ),
    );
  }
}
