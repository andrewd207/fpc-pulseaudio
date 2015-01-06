program pulse_simple_audio_cat_test;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, Sysutils,
  ctypes, pipes, pulse_simple, pulse_sample, pulse_def;

const
  BUFSIZE = 1024;
var
  s: PPASimple;
  ss: TPASampleSpec;
  ret: Integer;
  error: cint;
  buf: array[0..BUFSIZE-1] of byte;
  r: csize_t;
  stdin: TInputPipeStream;

begin
  ss.Init;
  ss.Format:= sfS16LE;
  ss.Rate:=44100;
  ss.Channels:=2;

  stdin := TInputPipeStream.Create(StdInputHandle);

  s := TPASimple.New(nil,'Andrew Test App', sdPLAYBACK, nil, 'testaudio', @ss, nil, nil, @error);
  WriteLn('Test');
  if s <> nil then
  begin
    try
      while true do //not stdin.eof(stdin) do
      begin
        //WriteLn('Reading...');
        r := stdin.Read(buf, sizeof(buf));
        //WriteLn('Read: ',r);
        if r > 0 then
          s^.Write(@buf, r, @error)
        else
          break;
      end;
    except

      on e: exception do
      begin
        WriteLn('exception');
        writeln(e.Message);
      end;
    end;
    s^.Drain(@error);
    s^.Free;
  end;
end.

