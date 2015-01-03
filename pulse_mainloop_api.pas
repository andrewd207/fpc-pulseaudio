{***
  This file is part of PulseAudio.

  Copyright 2004-2006 Lennart Poettering
  Copyright 2006 Pierre Ossman <ossman@cendio.se> for Cendio AB

  PulseAudio is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation; either version 2.1 of the
  License, or (at your option) any later version.

  PulseAudio is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with PulseAudio; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA.
***}


unit pulse_mainloop_api;

{$mode objfpc}{$H+}
{$CALLING cdecl}
{$PACKRECORDS c}


interface

uses
  Classes, SysUtils, pulse_version, ctypes, unix;

type


  {** An abstract mainloop API vtable *}
  PPAMainLoopAPI = ^TPAMainLoopAPI;

  {** A bitmask for IO events *}
  TPAIOEventFlags = (
    PA_IO_EVENT_NULL = 0,     {**< No event *}
    PA_IO_EVENT_INPUT = 1,    {**< Input event *}
    PA_IO_EVENT_OUTPUT = 2,   {**< Output event *}
    PA_IO_EVENT_HANGUP = 4,   {**< Hangup event *}
    PA_IO_EVENT_ERROR = 8     {**< Error event *}
    );

  {** An opaque IO event source object *}
  PPAIOEvent = ^TPAIOEvent;
  TPAIOEvent = record
  end;

  {** An IO event callback prototype \since 0.9.3 *}
  TPAIOEventCB = procedure(ea: PPAMainLoopAPI; e: PPAIOEvent; fd: cint; events: TPAIOEventFlags; userdata: pointer);

  {** A IO event destroy callback prototype \ since 0.9.3 *}
  TPAIOEventDestroyCB = procedure(a: PPAMainLoopAPI; e: PPAIOEvent; userdata: Pointer);

  {** An opaque timer event source object *}
  PPATimeEvent = ^TPATimeEvent;
  TPATimeEvent = record
  end;

  {** A time event callback prototype \since 0.9.3 *}
  TPATimeEventCB = procedure(a: PPAMainLoopAPI; e :PPATimeEvent; {const} tv: ptimeval; userdata: pointer);

  {** A time event destroy callback prototype \ since 0.9.3 *}
  TPATimeEventDestroyCB = procedure (a: PPAMainLoopAPI; e :PPATimeEvent; userdata: pointer);

  {** An opaque deferred event source object. Events of this type are triggered once in every main loop iteration *}
  PPADeferEvent = ^TPADeferEvent;
  TPADeferEvent = record
  end;

  {** A defer event callback prototype \since 0.9.3 *}
  TPADeferEventCB = procedure (a: PPAMainLoopAPI; e: PPADeferEvent; userdata: pointer);
  {** A defer event destroy callback prototype \ since 0.9.3 *}
  TPADeferEventDestroyCB = procedure (a: PPAMainLoopAPI; e: PPADeferEvent; userdata: pointer);

  TPAMainLoopCB = procedure (m : PPAMainLoopAPI; userdata: pointer);

  {** An abstract mainloop API vtable *}

  { TPAMainLoopAPI }

  TPAMainLoopAPI = object
    {** A pointer to some private, arbitrary data of the main loop implementation *}
    userdata: pointer;

    {** Create a new IO event source object *}
    io_new: function (a :PPAMainLoopAPI; fd: cint; events: TPAIOEventFlags; cb: TPAIOEventCB; userdata: pointer): PPAIOEvent;
    {** Enable or disable IO events on this object *}
    io_enable: procedure (e: PPAIOEvent; events: TPAIOEventFlags);
    {** Free a IO event source object *}
    io_free: procedure (e: PPAIOEvent);
    {** Set a function that is called when the IO event source is destroyed. Use this to free the userdata argument if required *}
    io_set_destroy: procedure (e: PPAIOEvent; cb: TPAIOEventDestroyCB);
    {** Create a new timer event source object for the specified Unix time *}
    time_new: function (a: TPAMainLoopAPI; {const} tv :ptimeval; cb :TPATimeEventCB; userdata: pointer): PPATimeEvent;
    {** Restart a running or expired timer event source with a new Unix time *}
    time_restart: procedure (e: PPATimeEvent; {const} tv :ptimeval);
    {** Free a deferred timer event source object *}
    time_free: procedure (e: PPATimeEvent);
    {** Set a function that is called when the timer event source is destroyed. Use this to free the userdata argument if required *}
    time_set_destroy: procedure (e: PPATimeEvent; cb: TPATimeEventDestroyCB);

    {** Create a new deferred event source object *}
    defer_new: function (a: PPAMainLoopAPI; cb: TPADeferEventCB; userdata: pointer): PPADeferEvent;
    {** Enable or disable a deferred event source temporarily *}
    defer_enable: procedure (e: PPADeferEvent; b: cint);
    {** Free a deferred event source object *}
    defer_free: procedure (e: PPADeferEvent);
    {** Set a function that is called when the deferred event source is destroyed. Use this to free the userdata argument if required *}
    defer_set_destroy: procedure (e: PPADeferEvent; c: TPADeferEventDestroyCB);

    {** Exit the main loop and return the specified retval*}
    quit: procedure (a: PPAMainLoopAPI; retval: cint);
    procedure Once(callback: TPAMainLoopCB; auserdata: pointer);
  end;



{** Run the specified callback function once from the main loop using an anonymous defer event. Note that this performs
 * multiple mainloop operations non-atomically. If, for example, you are using a \ref pa_threaded_mainloop, you will need to
 * take the mainloop lock before this call. *}
procedure pa_mainloop_api_once(m: PPAMainLoopAPI; callback: TPAMainLoopCB; userdata: pointer) external;




implementation

{ TPAMainLoopAPI }

procedure TPAMainLoopAPI.Once(callback: TPAMainLoopCB; auserdata: pointer);
begin
  pa_mainloop_api_once(@self, callback, auserdata);
end;

end.

