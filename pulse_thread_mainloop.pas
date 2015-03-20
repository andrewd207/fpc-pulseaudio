{***
  This file is part of PulseAudio.

  Copyright 2006 Lennart Poettering
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
unit pulse_thread_mainloop;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, ctypes, pulse_mainloop_api;

type
  PPAThreadedMainloop = ^TPAThreadedMainloop;

  { TPAThreadedMainloop }

  TPAThreadedMainloop = object sealed
    function  New: PPAThreadedMainloop;
    procedure Free;
    function  Start: cint;
    procedure Stop;
    procedure Lock;
    procedure Unlock;
    procedure Wait;
    procedure Signal(WaitForAccept: Boolean);
    procedure Accept;
    function  GetReturnValue: cint;
    function  GetAPI: PPAMainLoopAPI;
    function  InThread: Boolean;
    procedure SetName(AName: Utf8String);
  end;


function pa_threaded_mainloop_new: PPAThreadedMainloop; external;

{* Free a threaded main loop object. If the event loop thread is
 * still running, terminate it with pa_threaded_mainloop_stop()
 * first. }
procedure pa_threaded_mainloop_free(m: PPAThreadedMainloop); external;

{* Start the event loop thread. }
function pa_threaded_mainloop_start(m: PPAThreadedMainloop): cint; external;

{* Terminate the event loop thread cleanly. Make sure to unlock the
 * mainloop object before calling this function. }
procedure pa_threaded_mainloop_stop(m: PPAThreadedMainloop); external;

{* Lock the event loop object, effectively blocking the event loop
 * thread from processing events. You can use this to enforce
 * exclusive access to all objects attached to the event loop. This
 * lock is recursive. This function may not be called inside the event
 * loop thread. Events that are dispatched from the event loop thread
 * are executed with this lock held. }
procedure pa_threaded_mainloop_lock(m: PPAThreadedMainloop); external;

{* Unlock the event loop object, inverse of pa_threaded_mainloop_lock() }
procedure pa_threaded_mainloop_unlock(m: PPAThreadedMainloop); external;

{* Wait for an event to be signalled by the event loop thread. You
 * can use this to pass data from the event loop thread to the main
 * thread in a synchronized fashion. This function may not be called
 * inside the event loop thread. Prior to this call the event loop
 * object needs to be locked using pa_threaded_mainloop_lock(). While
 * waiting the lock will be released. Immediately before returning it
 * will be acquired again. This function may spuriously wake up even
 * without pa_threaded_mainloop_signal() being called. You need to
 * make sure to handle that! }
procedure pa_threaded_mainloop_wait(m: PPAThreadedMainloop); external;

{* Signal all threads waiting for a signalling event in
 * pa_threaded_mainloop_wait(). If wait_for_release is non-zero, do
 * not return before the signal was accepted by a
 * pa_threaded_mainloop_accept() call. While waiting for that condition
 * the event loop object is unlocked. }
procedure pa_threaded_mainloop_signal(m: PPAThreadedMainloop; wait_for_accept: cint); external;

{* Accept a signal from the event thread issued with
 * pa_threaded_mainloop_signal(). This call should only be used in
 * conjunction with pa_threaded_mainloop_signal() with a non-zero
 * wait_for_accept value.  }
procedure pa_threaded_mainloop_accept(m: PPAThreadedMainloop); external;

{* Return the return value as specified with the main loop's
 * pa_mainloop_quit() routine. }
function pa_threaded_mainloop_get_retval(m: PPAThreadedMainloop): cint; external;

{* Return the main loop abstraction layer vtable for this main loop.
 * There is no need to free this object as it is owned by the loop
 * and is destroyed when the loop is freed. }
function pa_threaded_mainloop_get_api(m: PPAThreadedMainloop): PPAMainLoopAPI; external;

{* Returns non-zero when called from within the event loop thread. \since 0.9.7 }
function pa_threaded_mainloop_in_thread(m: PPAThreadedMainloop): cint; external;

{* Sets the name of the thread. \since 5.0 }
procedure pa_threaded_mainloop_set_name(m: PPAThreadedMainloop; {const} mane: PChar); external;

implementation

{ TPAThreadedMainloop }

function TPAThreadedMainloop.New: PPAThreadedMainloop;
begin
  Result := pa_threaded_mainloop_new();
end;

procedure TPAThreadedMainloop.Free;
begin
  pa_threaded_mainloop_free(@Self);
end;

function TPAThreadedMainloop.Start: cint;
begin
  Result := pa_threaded_mainloop_start(@Self);
end;

procedure TPAThreadedMainloop.Stop;
begin
  pa_threaded_mainloop_stop(@Self);
end;

procedure TPAThreadedMainloop.Lock;
begin
  pa_threaded_mainloop_lock(@Self);
end;

procedure TPAThreadedMainloop.Unlock;
begin
  pa_threaded_mainloop_unlock(@Self);
end;

procedure TPAThreadedMainloop.Wait;
begin
  pa_threaded_mainloop_wait(@Self);
end;

procedure TPAThreadedMainloop.Signal(WaitForAccept: Boolean);
begin
  pa_threaded_mainloop_signal(@Self, Ord(WaitForAccept));
end;

procedure TPAThreadedMainloop.Accept;
begin
  pa_threaded_mainloop_accept(@Self);
end;

function TPAThreadedMainloop.GetReturnValue: cint;
begin
  Result := pa_threaded_mainloop_get_retval(@Self);
end;

function TPAThreadedMainloop.GetAPI: PPAMainLoopAPI;
begin
  Result := pa_threaded_mainloop_get_api(@Self);
end;

function TPAThreadedMainloop.InThread: Boolean;
begin
  Result := pa_threaded_mainloop_in_thread(@Self) <> 0;

end;

procedure TPAThreadedMainloop.SetName(AName: Utf8String);
begin
  pa_threaded_mainloop_set_name(@Self, PChar(AName));
end;

end.

