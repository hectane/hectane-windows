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

[Files]
Source: "hectane-386.exe"; DestDir: "{app}"; DestName: "{#AppExe}"; Check: not Is64BitInstallMode
Source: "hectane-amd64.exe"; DestDir: "{app}"; DestName: "{#AppExe}"; Check: Is64BitInstallMode

; TODO: register Windows service
