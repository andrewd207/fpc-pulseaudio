{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pulse_simple_pkg;

interface

uses
  pulse_channelmap, pulse_def, pulse_sample, pulse_simple, pulse_version, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pulse_simple_pkg', @Register);
end.
