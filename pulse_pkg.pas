{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pulse_pkg;

interface

uses
  pulse_channelmap, pulse_def, pulse_sample, pulse_version, pulse_rtclock, 
  pulse_mainloop_api, pulse_format, pulse_proplist, pulse_operation, 
  pulse_volume, pulse_context, pulse_error, pulse_stream, pulse_scache, 
  pulse_subscribe, pulse_util, pulse_timeval, pulse_thread_mainloop, 
  pulse_mainloop_signal, pulse_mainloop, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pulse_pkg', @Register);
end.
