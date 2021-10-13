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
unit pulse_context;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, pulse_sample, pulse_def, pulse_mainloop_api, pulse_operation,
  pulse_proplist, ctypes;

type
{** An opaque connection context to a daemon *}
  PPAContext = ^TPAContext;


{** Generic notification callback prototype *}
   TPAContextNotifyCB = procedure(C: PPAContext; userdata: pointer);

{** A generic callback for operation completion *}
   TPAContextSuccessCB = procedure(c: PPAContext; success: cint; userdata: Pointer);

{** A callback for asynchronous meta/policy event messages. The set
 * of defined events can be extended at any time. Also, server modules
 * may introduce additional message types so make sure that your
 * callback function ignores messages it doesn't know. \since
 * 0.9.15 *}
   TPAContextEventCB = procedure(c: PPAContext; {const} name: pchar; p: PPAProplist; userdata: pointer);

  { TPAContext }
  {See pulse_intospect.pas TPAContextHelper for additional methods }
  TPAContext = object {sealed}
    function  New(AMainLoop: PPAMainLoopAPI; AName: PChar): PPAContext; static;
    function  NewWithPropList(AMainLoop: PPAMainLoopAPI; AName: PChar; APropList: PPAProplist): PPAContext; static;
    procedure Unref;
    function  Ref: PPAContext;
    procedure SetStateCallback(ACB: TPAContextNotifyCB; AUserData: Pointer);
    procedure SetEventCallback(ACB: TPAContextEventCB; AUserData: Pointer);
    function  ErrNo: cint;
    function  IsPending: Boolean;
    function  GetState: TPAContextState;
    function  Connect(AServer: PChar; AFlags: TPAContextFlags; API: PPASpawnApi): cint;
    procedure Disconnect;
    function  Drain(ACB: TPAContextNotifyCB; UserData: Pointer): PPAOperation;
    function  ExitDaemon(ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
    function  SetDefaultSink(AName: PChar; ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
    function  SetDefaultSource(AName: PChar; ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
    function  IsLocal: Boolean;
    function  SetName(AName: PChar; ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
    function  GetServer: PChar;
    function  GetProtocolVersion: LongWord;
    function  GetServerProtocolVersion: LongWord;
    function  ProplistUpdate(AMode: TPAUpdateMode; AList: PPAProplist; ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
    function  ProplistRemove(Keys: PPChar; ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
    function  GetIndex: LongWord; // servers index of us the client
    function  RtTimeNew(uSec: QWord; ACB: TPATimeEventCB; Userdata: Pointer): PPATimeEvent;
    procedure RtTimeRestart(AEvent: PPATimeEvent; uSec: QWord);
    function  GetTileSize(ASpec: PPASampleSpec): csize_t;
    function  LoadCookieFromFile(ACookieFilePath: PChar): cint;
  end;

{** Instantiate a new connection context with an abstract mainloop API
 * and an application name. It is recommended to use pa_context_new_with_proplist()
 * instead and specify some initial properties.*}
function pa_context_new(mainloop: PPAMainloopAPI; {const} name: pchar): PPAContext external;

{** Instantiate a new connection context with an abstract mainloop API
 * and an application name, and specify the initial client property
 * list. \since 0.9.11 *}
function pa_context_new_with_proplist(mainloop: PPAMainloopAPI; {const} name: pchar; proplist: PPAProplist): PPAContext external;

{** Decrease the reference counter of the context by one *}
procedure pa_context_unref(c: PPAContext) external;

{** Increase the reference counter of the context by one *}
function pa_context_ref(c: PPAContext): PPAContext external;

{** Set a callback function that is called whenever the context status changes *}
procedure pa_context_set_state_callback(c: PPAContext; cb: TPAContextNotifyCB; userdata: pointer) external;

{** Set a callback function that is called whenever a meta/policy
 * control event is received. \since 0.9.15 *}
procedure pa_context_set_event_callback(p: PPAContext; cb: TPAContextEventCB; userdata: pointer) external;

{** Return the error number of the last failed operation *}
function pa_context_errno(c: PPAContext): cint external;

{** Return non-zero if some data is pending to be written to the connection *}
function pa_context_is_pending(c: PPAContext): cint external;

{** Return the current context status *}
function pa_context_get_state(c: PPAContext): TPAContextState external;

{** Connect the context to the specified server. If server is NULL,
connect to the default server. This routine may but will not always
return synchronously on error. Use pa_context_set_state_callback() to
be notified when the connection is established. If flags doesn't have
PA_CONTEXT_NOAUTOSPAWN set and no specific server is specified or
accessible a new daemon is spawned. If api is non-NULL, the functions
specified in the structure are used when forking a new child
process. *}
function pa_context_connect(c: PPAContext; {const} server: Pchar; flags: TPAContextFlags; {const} api: PPASpawnApi): cint external;

{** Terminate the context connection immediately *}
procedure pa_context_disconnect(c: PPAContext) external;

{** Drain the context. If there is nothing to drain, the function returns NULL *}
function pa_context_drain(c: PPAContext; cb: TPAContextNotifyCB; userdata: pointer): PPAOperation external;

{** Tell the daemon to exit. The returned operation is unlikely to
 * complete successfully, since the daemon probably died before
 * returning a success notification *}
function pa_context_exit_daemon(c: PPAContext; cb: TPAContextSuccessCB; userdata: pointer): PPAOperation external;

{** Set the name of the default sink. *}
function pa_context_set_default_sink(c: PPAContext; {const} name: pchar; cb: TPAContextSuccessCB; userdata: pointer): PPAOperation external;

{** Set the name of the default source. *}
function pa_context_set_default_source(c: PPAContext; {const} name: pchar; cb: TPAContextSuccessCB; userdata: pointer): PPAOperation external;

{** Returns 1 when the connection is to a local daemon. Returns negative when no connection has been made yet. *}
function  pa_context_is_local(c: PPAContext): cint external;

{** Set a different application name for context on the server. *}
function pa_context_set_name(c: PPAContext; {const} name: pchar; cb: TPAContextSuccessCB; userdata: pointer): PPAOperation external;

{** Return the server name this context is connected to. *}
function pa_context_get_server(c: PPAContext): pchar external;

{** Return the protocol version of the library. *}
function pa_context_get_protocol_version(c: PPAContext): LongWord external;

{** Return the protocol version of the connected server. *}
function pa_context_get_server_protocol_version(c: PPAContext): LongWord external;

{** Update the property list of the client, adding new entries. Please
 * note that it is highly recommended to set as much properties
 * initially via pa_context_new_with_proplist() as possible instead a
 * posteriori with this function, since that information may then be
 * used to route streams of the client to the right device. \since 0.9.11 *}
function pa_context_proplist_update(c: PPAContext; mode: TPAUpdateMode; p : PPAProplist; cb : TPAContextSuccessCB; userdata: pointer): PPAOperation external;

{** Update the property list of the client, remove entries. \since 0.9.11 *}
function pa_context_proplist_remove(c: PPAContext; {const} {const} keys: PPChar; cb :TPAContextSuccessCB; userdata: pointer): PPAOperation external;

{** Return the client index this context is
 * identified in the server with. This is useful for usage with the
 * introspection functions, such as pa_context_get_client_info(). \since 0.9.11 *}
function pa_context_get_index(s: PPAContext): LongWord external;

{** Create a new timer event source for the specified time (wrapper
 * for mainloop->time_new). \since 0.9.16 *}
function pa_context_rttime_new(c: PPAContext; usec: QWord; cb: TPATimeEventCB; userdata: pointer): PPATimeEvent external;

{** Restart a running or expired timer event source (wrapper for
 * mainloop->time_restart). \since 0.9.16 *}
procedure pa_context_rttime_restart(c: PPAContext; e: PPATimeEvent; usec: QWord) external;

{** Return the optimal block size for passing around audio buffers. It
 * is recommended to allocate buffers of the size returned here when
 * writing audio data to playback streams, if the latency constraints
 * permit this. It is not recommended writing larger blocks than this
 * because usually they will then be split up internally into chunks
 * of this size. It is not recommended writing smaller blocks than
 * this (unless required due to latency demands) because this
 * increases CPU usage. If ss is NULL you will be returned the
 * byte-exact tile size. If you pass a valid ss, then the tile size
 * will be rounded down to multiple of the frame size. This is
 * supposed to be used in a construct such as
 * pa_context_get_tile_size(pa_stream_get_context(s),
 * pa_stream_get_sample_spec(ss)); \since 0.9.20 *}
function pa_context_get_tile_size(c: PPAContext; {const} ss: PPASampleSpec): csize_t external;

{** Load the authentication cookie from a file. This function is primarily
 * meant for PulseAudio's own tunnel modules, which need to load the cookie
 * from a custom location. Applications don't usually need to care about the
 * cookie at all, but if it happens that you know what the authentication
 * cookie is and your application needs to load it from a non-standard
 * location, feel free to use this function. \since 5.0 *}
function pa_context_load_cookie_from_file(c: PPAContext; {const} cookie_file_path: pchar): cint external;

implementation

{ TPAContext }

function TPAContext.New(AMainLoop: PPAMainLoopAPI; AName: PChar): PPAContext;
begin
  Result := pa_context_new(AMainLoop, AName);
end;

function TPAContext.NewWithPropList(AMainLoop: PPAMainLoopAPI; AName: PChar;
  APropList: PPAProplist): PPAContext;
begin
  Result := pa_context_new_with_proplist(AMainLoop, AName, APropList);
end;

procedure TPAContext.Unref;
begin
  pa_context_unref(@self);
end;

function TPAContext.Ref: PPAContext;
begin
  Result := pa_context_ref(@self);
end;

procedure TPAContext.SetStateCallback(ACB: TPAContextNotifyCB; AUserData: Pointer);
begin
  pa_context_set_state_callback(@self, ACB, AUserData);
end;

procedure TPAContext.SetEventCallback(ACB: TPAContextEventCB; AUserData: Pointer);
begin
  pa_context_set_event_callback(@self, Acb, AUserData);
end;

function TPAContext.ErrNo: cint;
begin
  Result := pa_context_errno(@self);
end;

function TPAContext.IsPending: Boolean;
begin
  Result := pa_context_is_pending(@self) <> 0;
end;

function TPAContext.GetState: TPAContextState;
begin
   Result := pa_context_get_state(@self);
end;

function TPAContext.Connect(AServer: PChar; AFlags: TPAContextFlags; API: PPASpawnApi): cint;
begin
  Result := pa_context_connect(@self, AServer, AFlags, API);
end;

procedure TPAContext.Disconnect;
begin
  pa_context_disconnect(@self);
end;

function TPAContext.Drain(ACB: TPAContextNotifyCB; UserData: Pointer): PPAOperation;
begin
  Result := pa_context_drain(@self, ACB, UserData);
end;

function TPAContext.ExitDaemon(ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
begin
  Result := pa_context_exit_daemon(@self, Acb, userdata);
end;

function TPAContext.SetDefaultSink(AName: PChar; ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_default_sink(@self, AName, Acb, userdata);
end;

function TPAContext.SetDefaultSource(AName: PChar; ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_default_source(@self, AName, ACB, userdata);
end;

function TPAContext.IsLocal: Boolean;
begin
  Result := pa_context_is_local(@self) <> 0;
end;

function TPAContext.SetName(AName: PChar; ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_name(@self, AName, ACB, userdata);
end;

function TPAContext.GetServer: PChar;
begin
  Result := pa_context_get_server(@self);
end;

function TPAContext.GetProtocolVersion: LongWord;
begin
  Result := pa_context_get_protocol_version(@self);
end;

function TPAContext.GetServerProtocolVersion: LongWord;
begin
  Result := pa_context_get_server_protocol_version(@self);
end;

function TPAContext.ProplistUpdate(AMode: TPAUpdateMode; AList: PPAProplist;
  ACB: TPAContextSuccessCB; userdata: Pointer): PPAOperation;
begin
  Result := pa_context_proplist_update(@self, AMode, AList, ACB, userdata);
end;

function TPAContext.ProplistRemove(Keys: PPChar; ACB: TPAContextSuccessCB;
  userdata: Pointer): PPAOperation;
begin
  Result := pa_context_proplist_remove(@self, keys, ACB, userdata);
end;

function TPAContext.GetIndex: LongWord;
begin
  Result := pa_context_get_index(@self);
end;

function TPAContext.RtTimeNew(uSec: QWord; ACB: TPATimeEventCB;
  Userdata: Pointer): PPATimeEvent;
begin
  Result := pa_context_rttime_new(@self, uSec, ACB, Userdata);
end;

procedure TPAContext.RtTimeRestart(AEvent: PPATimeEvent; uSec: QWord);
begin
  pa_context_rttime_restart(@self, AEvent, uSec);
end;

function TPAContext.GetTileSize(ASpec: PPASampleSpec): csize_t;
begin
  Result := pa_context_get_tile_size(@self, ASpec);
end;

function TPAContext.LoadCookieFromFile(ACookieFilePath: PChar): cint;
begin
  Result := pa_context_load_cookie_from_file(@self, ACookieFilePath);
end;

end.

