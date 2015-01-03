{***
  This file is part of PulseAudio.

  Copyright 2004-2006 Lennart Poettering
  Copyright 2006 Pierre Ossman <ossman@cendio.se> for Cendio AB

  PulseAudio is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as published
  by the Free Software Foundation; either version 2 of the License,
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
unit pulse_version;

{$mode objfpc}{$H+}
{$PACKRECORDS c}
{$CALLING cdecl}

interface

uses
  Classes, SysUtils;

const
  pa_get_headers_version = '5.0.0';
  {** The current API version. Version 6 relates to Polypaudio
 * 0.6. Prior versions (i.e. Polypaudio 0.5.1 and older) have
 * PA_API_VERSION undefined. Please note that this is only ever
 * increased on incompatible API changes!  *}
 PA_API_VERSION = 12;

{** The current protocol version. Version 8 relates to Polypaudio
 * 0.8/PulseAudio 0.9. *}
 PA_PROTOCOL_VERSION = 29;

{** The major version of PA. \since 0.9.15 *}
 PA_MAJOR = 5;

{** The minor version of PA. \since 0.9.15 *}
 PA_MINOR = 0;

{** The micro version of PA (will always be 0 from v1.0 onwards). \since 0.9.15 *}
 PA_MICRO = 0;

function pa_get_library_version: PChar external;

function PA_CHECK_VERSION(major,minor,micro: Integer): Boolean;

implementation

function PA_CHECK_VERSION(major, minor, micro: Integer): Boolean;
begin
  Result :=
      (PA_MAJOR > (major))
  or ((PA_MAJOR = major) and (PA_MINOR > (minor)))
  or (((PA_MAJOR = major) and (PA_MINOR = minor) and (PA_MICRO >= micro)));
end;

end.

