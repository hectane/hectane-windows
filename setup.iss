; Windows Installer for Hectane
; Copyright 2015 - Nathan Osman

; To compile this installer, place the compiled hectane binaries in this
; directory and ensure they are named hectane-386.exe and hectane-amd64.exe.

#define AppId        "{{9CB5E0BE-8314-404E-9606-8DB27F709525}"
#define AppName      "Hectane"
#define AppVersion   "0.3.0"
#define AppPublisher "Nathan Osman"
#define AppURL       "https://github.com/hectane/hectane"
#define AppExe       "hectane.exe"

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
DefaultDirName={pf}\{#AppName}
OutputBaseFilename=setup
Compression=lzma2
SolidCompression=yes
WizardImageFile=image.bmp
WizardSmallImageFile=image_small.bmp
ArchitecturesInstallIn64BitMode=x64
MinVersion=6.0

[Files]
Source: "hectane-386.exe"; DestDir: "{app}"; DestName: "{#AppExe}"; Check: not Is64BitInstallMode; BeforeInstall: PreInstall; AfterInstall: PostInstall
Source: "hectane-amd64.exe"; DestDir: "{app}"; DestName: "{#AppExe}"; Check: Is64BitInstallMode; BeforeInstall: PreInstall; AfterInstall: PostInstall

[Code]

// It would be nice if we could use [Run] entries but the return code is not checked,
// therefore we must run the service installation code ourselves and check for errors

function ServiceCommand(Command: String): Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec(ExpandConstant('{app}\{#AppExe}'), Command, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

// The service should only be installed if the executable didn't exist before
// installation. A global variable is required to keep track of this so that
// after installation, the appropriate action can be taken.

var 
  FileExisted: Boolean;

procedure PreInstall();
begin
  FileExisted := FileExists(ExpandConstant('{app}\{#AppExe}'));
end;

// The service will automatically be stopped and restarted by the Restart
// Manager if it was running prior to installation.

procedure PostInstall();
begin
  if not FileExisted then
  begin
    WizardForm.StatusLabel.Caption := 'Installing & starting service...';
    if ServiceCommand(ExpandConstant('-directory "{app}\data" install')) then
    begin
      if not ServiceCommand('start') then
        MsgBox('Unable to start service.', mbError, MB_OK);
    end
    else
      MsgBox('Unable to install service.', mbError, MB_OK);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    UninstallProgressForm.StatusLabel.Caption := 'Stopping & removing service...';
    ServiceCommand('stop');
    ServiceCommand('remove'); 
  end;
end;