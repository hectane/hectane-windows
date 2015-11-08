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
Source: "hectane-386.exe"; DestDir: "{app}"; DestName: "{#AppExe}"; Check: not Is64BitInstallMode
Source: "hectane-amd64.exe"; DestDir: "{app}"; DestName: "{#AppExe}"; Check: Is64BitInstallMode

[Code]

// It would be nice if we could use [Run] entries but the return code is not checked,
// therefore we must run the service installation code ourselves and check for errors

function ServiceCommand(Command: String): Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec(ExpandConstant('{app}\{#AppExe}'), Command, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if not RmSessionStarted() then
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