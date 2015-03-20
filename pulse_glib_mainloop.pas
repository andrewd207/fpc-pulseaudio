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
unit pulse_glib_mainloop;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, ctypes, pulse_mainloop_api, glib2;

type
  PPAGlibMainloop = ^TPAGlibMainloop;

  { TPAGlibMainloop }

  TPAGlibMainloop = object sealed
    function  New(AContext: PGMainContext): PPAGlibMainloop; static;
    procedure Free;
    function  GetAPI: PPAMainLoopAPI;
  end;

{** Create a new GLIB main loop object for the specified GLIB main
 * loop context. Takes an argument c for the
 * GMainContext to use. If c is NULL the default context is used. *}
function pa_glib_mainloop_new(c: PGMainContext): PPAGlibMainloop; external;

{** Free the GLIB main loop object *}
procedure pa_glib_mainloop_free(g: PPAGlibMainloop); external;

{** Return the abstract main loop API vtable for the GLIB main loop
    object. No need to free the API as it is owned by the loop
    and is destroyed when the loop is freed. *}
function pa_glib_mainloop_get_api(g: PPAGlibMainloop): PPAMainLoopAPI; external;

implementation

{ TPAGlibMainloop }

function TPAGlibMainloop.New(AContext: PGMainContext): PPAGlibMainloop;
begin
  Result := pa_glib_mainloop_new(AContext);
end;

procedure TPAGlibMainloop.Free;
begin
  pa_glib_mainloop_free(@Self);
end;

function TPAGlibMainloop.GetAPI: PPAMainLoopAPI;
begin
  Result := pa_glib_mainloop_get_api(@Self);
end;

end.

