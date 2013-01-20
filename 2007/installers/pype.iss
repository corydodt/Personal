[Files]
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\changelog.txt"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\gpl.txt"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\helpc.pyd"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\pype.exe"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\python23.dll"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\readme.txt"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\stc-styles.rc.cfg"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\stc_c.pyd"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\wxc.pyd"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\wxmsw24uh.dll"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\wxProject.py"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\zlib.pyd"; DestDir: "{app}\."; Flags: ignoreversion
Source: "C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype\_sre.pyd"; DestDir: "{app}\."; Flags: ignoreversion
[Dirs]
Name: "{app}\.\"
[Setup]
AppName=Python Programmer's Editor
AppVerName=Python Programmer's Editor 1.9
DefaultDirName={pf}\pype
OutputBaseFilename=pype-1.9-setup
DefaultGroupName=Python Programmer's Editor
OutputDir=C:\Documents and Settings\cory\Desktop\PyPE1.9-win-unicode\pype
[Icons]
Name: "{group}\PyPE"; Filename: "{app}\pype.exe"
Name: "{group}\Uninstall PyPE"; Filename: "{uninstallexe}"
