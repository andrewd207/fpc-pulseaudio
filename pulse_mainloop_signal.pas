{**
  This file is part of PulseAudio.

  Copyright 2004-2008 Lennart Poettering
  Copyright 2006 Pierre Ossman <ossman@cendio.se> for Cendio AB

  PulseAudio is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as published
  by the Free Software Foundation; either version 2.1 of the License,
  or (at your option) any later version.

  PulseAudio is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with PulseAudio; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA.
***}
unit pulse_mainloop_signal;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, ctypes, pulse_mainloop_api;

type
{* An opaque UNIX signal event source object *}
  PPASignalEvent = ^TPASignalEvent;

  {* Callback prototype for signal events *}
  TPASignalCB = procedure(AAPI: PPAMainLoopAPI; E: PPASignalEvent; ASig: cint; UserData: Pointer); cdecl;

{* Destroy callback prototype for signal events *}
  TPASignalDestroyCB = procedure(AAPI: PPAMainLoopAPI; E: PPASignalEvent; UserData: Pointer); cdecl;

  { TPASignalEvent }

  TPASignalEvent = object sealed
    function  New(ASig: cint; ACallback: TPASignalCB; AUserData: Pointer): PPASignalEvent; static;
    procedure Free;
    procedure SetDestroyCallback(ACB: TPASignalDestroyCB);
  end;


{* Initialize the UNIX signal subsystem and bind it to the specified main loop *}
function pa_signal_init(api: PPAMainloopAPI): cint; external;

{* Cleanup the signal subsystem *}
procedure pa_signal_done; external;

{* Create a new UNIX signal event source object *}
function pa_signal_new(sig: cint; callback: TPASignalCB; userdata: pointer): PPASignalEvent; external;

{* Free a UNIX signal event source object *}
procedure pa_signal_free(e: PPASignalEvent); external;

{* Set a function that is called when the signal event source is destroyed. Use this to free the userdata argument if required *}
procedure pa_signal_set_destroy(e: PPASignalEvent; callback: TPASignalDestroyCB); external;

implementation

{ TPASignalEvent }

function TPASignalEvent.New(ASig: cint; ACallback: TPASignalCB;
  AUserData: Pointer): PPASignalEvent;
begin
  Result := pa_signal_new(ASig, ACallback, AUserData);
end;

procedure TPASignalEvent.Free;
begin
  pa_signal_free(@Self);
end;

procedure TPASignalEvent.SetDestroyCallback(ACB: TPASignalDestroyCB);
begin
  pa_signal_set_destroy(@Self, ACB);
end;

end.

