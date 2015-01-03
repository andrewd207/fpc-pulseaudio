{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pulse_pkg;

interface

uses
  pulse_channelmap, pulse_def, pulse_sample, pulse_version, pulse_rtclock, 
  pulse_mainloop_api, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pulse_pkg', @Register);
end.
