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
unit pulse_util;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}
interface

uses
  Classes, SysUtils, ctypes;

//** Return the current username in the specified string buffer. */
function pa_get_user_name(s: PChar; l: csize_t): PChar; external;

//** Return the current hostname in the specified buffer. */
function pa_get_host_name(s: PChar; l: csize_t): PChar; external;

//** Return the fully qualified domain name in s */
function pa_get_fqdn(s: PChar; l: csize_t): PChar; external;

//** Return the home directory of the current user */
function pa_get_home_dir(s: PChar; l: csize_t): PChar; external;

//** Return the binary file name of the current process. This is not
// * supported on all architectures, in which case NULL is returned. */
function pa_get_binary_name(s: PChar; l: csize_t): PChar; external;

//** Return a pointer to the filename inside a path (which is the last
// * component). If passed NULL will return NULL. */
function pa_path_get_filename({const} p: PChar): PChar; external;

//** Wait t milliseconds */
function pa_msleep(t: culong): cint; external;


implementation

end.

