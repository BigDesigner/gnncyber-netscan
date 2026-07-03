; GNNscan - Inno Setup Installer Script
; Targets compiled Windows Flutter executable and bundles WebView2 runtime check.

[Setup]
AppId={{C82F6D18-7F1F-43DE-875C-B24DE7AA9D2B}
AppName=GNNcyber - NETscan
AppVersion=2.8.0
AppPublisher=BigDesigner
AppPublisherURL=https://github.com/BigDesigner/GNNscan
AppSupportURL=https://github.com/BigDesigner/GNNscan
AppUpdatesURL=https://github.com/BigDesigner/GNNscan
DefaultDirName={autopf}\GNNscan
DisableProgramGroupPage=yes
LicenseFile=README.md
OutputDir=.
OutputBaseFilename=GNNcyber_NETscan_Setup
SetupIconFile=assets\app.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\gnnscan.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on shared system files

[Icons]
Name: "{autoprograms}\GNNcyber - NETscan"; Filename: "{app}\gnnscan.exe"
Name: "{autodesktop}\GNNcyber - NETscan"; Filename: "{app}\gnnscan.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\gnnscan.exe"; Description: "{cm:LaunchProgram,GNNcyber - NETscan}"; Flags: nowait postinstall skipifsilent
; Download and install WebView2 silently after install if missing
Filename: "powershell.exe"; Parameters: "-NoProfile -Command ""Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/p/?LinkId=2124703' -OutFile '$env:TEMP\MicrosoftEdgeWebview2Setup.exe'; Start-Process -FilePath '$env:TEMP\MicrosoftEdgeWebview2Setup.exe' -ArgumentList '/silent /install' -Wait"""; StatusMsg: "Installing Microsoft Edge WebView2 Runtime (if missing)..."; Check: not IsWebView2Installed; Flags: runhidden

[Code]
// Helper function to check if Edge WebView2 Runtime is installed
function IsWebView2Installed: Boolean;
var
  RegPath: String;
  InstalledVersion: String;
begin
  RegPath := 'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}';
  Result := RegQueryStringValue(HKLM, RegPath, 'pv', InstalledVersion) or
            RegQueryStringValue(HKCU, RegPath, 'pv', InstalledVersion);
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;
