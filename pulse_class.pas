unit pulse_class;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, unixtype,
  pulse_mainloop,
  pulse_thread_mainloop, pulse_mainloop_api;

type

  { TPulse }

  TPulse = class(TComponent)
  private
    FThreaded: Boolean;
    FThreadLoop: PPAThreadedMainloop;
    FLoop: PPAMainloop;
    FAPI: PPAMainLoopAPI; // shared
    FRunning: Boolean;
    function GetLoop: Pointer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start(AThreaded: Boolean; ARunMainLoop: Boolean = False);
    // a live runtime mainloop handle: public (not published) since a raw
    // Pointer has no streamable RTTI and there's nothing to edit/stream at
    // design time.
    property Loop: Pointer read GetLoop; //returns the loop object, either threaded or not
  published
    property Threaded: Boolean read FThreaded;
  end;

implementation

{ TPulse }

function TPulse.GetLoop: Pointer;
begin
  if FThreaded then
    Result := FThreadLoop
  else
    Result := FLoop;
end;

constructor TPulse.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TPulse.Destroy;
begin
  // FAPI is owned and freed by the loop
  if Assigned(FThreadLoop) then
  begin
    FThreadLoop^.Stop;
    FThreadLoop^.Free;
  end
  else if Assigned(FLoop) then
  begin
    FLoop^.Free;
  end;
  inherited Destroy;
end;

procedure TPulse.Start(AThreaded: Boolean; ARunMainLoop: Boolean);
var
  lReturnValue: cint;
begin
  if FRunning then
    Exit;
  FThreaded:= AThreaded;
  if FThreaded then
  begin
    FThreadLoop := pa_threaded_mainloop_new(); // .New isn't static on this type
    FAPI := FThreadLoop^.GetAPI;
    FThreadLoop^.Start;
  end
  else
  begin
    FLoop := TPAMainloop.New;
    FAPI := FLoop^.GetAPI;
    if ARunMainLoop then
      FLoop^.Run(@lReturnValue);

  end;
end;

end.

