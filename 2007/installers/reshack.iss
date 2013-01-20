; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=Resource Hacker
AppVerName=Resource Hacker 3.4.0
AppPublisher=Angus Johnson
AppPublisherURL=http://www.users.on.net/johnson/resourcehacker/
AppSupportURL=http://www.users.on.net/johnson/resourcehacker/
AppUpdatesURL=http://www.users.on.net/johnson/resourcehacker/
DefaultDirName={pf}\Resource Hacker
DefaultGroupName=Resource Hacker
OutputBaseFileName=ResourceHacker-setup-3.4.0

[Files]
Source: "C:\temp\reshack\ResHacker.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\temp\reshack\*.*"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[INI]
Filename: "{app}\ResHacker.url"; Section: "InternetShortcut"; Key: "URL"; String: "http://www.users.on.net/johnson/resourcehacker/"

[Icons]
Name: "{group}\Resource Hacker"; Filename: "{app}\ResHacker.exe"
; NOTE: The following entry contains an English phrase ("on the Web"). You are free to translate it into another language if required.
Name: "{group}\Resource Hacker on the Web"; Filename: "{app}\ResHacker.url"
; NOTE: The following entry contains an English phrase ("Uninstall"). You are free to translate it into another language if required.
Name: "{group}\Uninstall Resource Hacker"; Filename: "{uninstallexe}"

[Run]
; NOTE: The following entry contains an English phrase ("Launch"). You are free to translate it into another language if required.
Filename: "{app}\ResHacker.exe"; Description: "Launch Resource Hacker"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\ResHacker.url"
