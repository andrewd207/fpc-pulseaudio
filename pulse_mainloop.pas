{***
  This file is part of PulseAudio.

  Copyright 2004-2006 Lennart Poettering
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
unit pulse_mainloop;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}
{$LinkLib pulse-mainloop-glib}

interface

uses
  Classes, SysUtils, ctypes, pulse_mainloop_api;

type
  PPAPollFd = ^TPAPollFd;
  TPAPollFd = record
  end;

  {** An opaque main loop object *}
  PPAMainloop = ^TPAMainloop;

  {** Generic prototype of a poll() like function *}
  TPAPollFunc = function(ufds: PPAPollFd; nfds: culong; timeout: cint; userdata: pointer): cint cdecl;

  { TPAMainloop }

  TPAMainloop = object{ sealed}
    function  New: PPAMainloop; static;
    procedure Free;
    function  Prepare(ATimeOut: cint): cint;
    function  Poll: cint;
    function  Dispatch: cint;
    function  GetReturnValue: cint;
    function  Iterate(Block: Boolean; ReturnValue: pcint): cint;
    function  Run(ReturnValue: pcint): cint;
    function  GetAPI: PPAMainLoopAPI;
    procedure Quit(r: cint);
    procedure Wakeup;
    procedure SetPollFunction(APollFunction: TPAPollFunc; AUserData: Pointer);
  end;



{** Allocate a new main loop object *}
function pa_mainloop_new: PPAMainloop; external;

{** Free a main loop object *}
procedure pa_mainloop_free(m: PPAMainloop); external;

{** Prepare for a single iteration of the main loop. Returns a negative value
on error or exit request. timeout specifies a maximum timeout for the subsequent
poll, or -1 for blocking behaviour. .*}
function pa_mainloop_prepare(m: PPAMainloop; timeout: cint): cint; external;

{** Execute the previously prepared poll. Returns a negative value on error.*}
function pa_mainloop_poll(m: PPAMainloop): cint; external;

{** Dispatch timeout, io and deferred events from the previously executed poll. Returns
a negative value on error. On success returns the number of source dispatched. *}
function pa_mainloop_dispatch(m: PPAMainloop): cint external;

{** Return the return value as specified with the main loop's quit() routine. *}
function pa_mainloop_get_retval(m: PPAMainloop): cint; external;

{** Run a single iteration of the main loop. This is a convenience function
for pa_mainloop_prepare(), pa_mainloop_poll() and pa_mainloop_dispatch().
Returns a negative value on error or exit request. If block is nonzero,
block for events if none are queued. Optionally return the return value as
specified with the main loop's quit() routine in the integer variable retval points
to. On success returns the number of sources dispatched in this iteration. *}
function pa_mainloop_iterate(m: PPAMainloop; block: cint; retval: pcint): cint external;

{** Run unlimited iterations of the main loop object until the main loop's quit() routine is called. *}
function pa_mainloop_run(m: PPAMainloop; retval: pcint): cint external;

{** Return the abstract main loop abstraction layer vtable for this
    main loop. No need to free the API as it is owned by the loop
    and is destroyed when the loop is freed. *}
function pa_mainloop_get_api(m: PPAMainloop): PPAMainLoopAPI; external;

{** Shutdown the main loop *}
procedure pa_mainloop_quit(m: PPAMainloop; r: cint); external;

{** Interrupt a running poll (for threaded systems) *}
procedure pa_mainloop_wakeup(m: PPAMainloop); external;


{** Change the poll() implementation *}
procedure pa_mainloop_set_poll_func(m: PPAMainloop; poll_func: TPAPollFunc;userdata: pointer); external;

implementation

{ TPAMainloop }

function TPAMainloop.New: PPAMainloop;
begin
  Result := pa_mainloop_new;
end;

procedure TPAMainloop.Free;
begin
  pa_mainloop_free(@Self);
end;

function TPAMainloop.Prepare(ATimeOut: cint): cint;
begin
  Result := pa_mainloop_prepare(@Self, ATimeOut);
end;

function TPAMainloop.Poll: cint;
begin
  Result := pa_mainloop_poll(@Self);
end;

function TPAMainloop.Dispatch: cint;
begin
  Result := pa_mainloop_dispatch(@Self);
end;

function TPAMainloop.GetReturnValue: cint;
begin
  Result := pa_mainloop_get_retval(@Self);
end;

function TPAMainloop.Iterate(Block: Boolean; ReturnValue: pcint): cint;
begin
  Result := pa_mainloop_iterate(@Self, Ord(Block), ReturnValue);
end;

function TPAMainloop.Run(ReturnValue: pcint): cint;
begin
  Result := pa_mainloop_run(@Self, ReturnValue);
end;

function TPAMainloop.GetAPI: PPAMainLoopAPI;
begin
  Result := pa_mainloop_get_api(@Self);
end;

procedure TPAMainloop.Quit(r: cint);
begin
  pa_mainloop_quit(@Self, r);
end;

procedure TPAMainloop.Wakeup;
begin
  pa_mainloop_wakeup(@Self);
end;

procedure TPAMainloop.SetPollFunction(APollFunction: TPAPollFunc; AUserData: Pointer);
begin
  pa_mainloop_set_poll_func(@Self, APollFunction, AUserData);
end;

end.

