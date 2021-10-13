{***
  This file is part of PulseAudio.

  Copyright 2007 Lennart Poettering

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
unit pulse_proplist;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, ctypes;

const
{** For streams: localized media name, formatted as UTF-8. E.g. 'Guns'N'Roses: Civil War'.*}
  PA_PROP_MEDIA_NAME                   = 'media.name';

{** For streams: localized media title if applicable, formatted as UTF-8. E.g. 'Civil War' *}
  PA_PROP_MEDIA_TITLE                  = 'media.title';

{** For streams: localized media artist if applicable, formatted as UTF-8. E.g. 'Guns'N'Roses' *}
  PA_PROP_MEDIA_ARTIST                 = 'media.artist';

{** For streams: localized media copyright string if applicable, formatted as UTF-8. E.g. 'Evil Record Corp.' *}
  PA_PROP_MEDIA_COPYRIGHT              = 'media.copyright';

{** For streams: localized media generator software string if applicable, formatted as UTF-8. E.g. 'Foocrop AudioFrobnicator' *}
  PA_PROP_MEDIA_SOFTWARE               = 'media.software';

{** For streams: media language if applicable, in standard POSIX format. E.g. 'de_DE' *}
  PA_PROP_MEDIA_LANGUAGE               = 'media.language';

{** For streams: source filename if applicable, in URI format or local path. E.g. '/home/lennart/music/foobar.ogg' *}
  PA_PROP_MEDIA_FILENAME               = 'media.filename';

{** For streams: icon for the media. A binary blob containing PNG image data *}
  PA_PROP_MEDIA_ICON                   = 'media.icon';

{** For streams: an XDG icon name for the media. E.g. 'audio-x-mp3' *}
  PA_PROP_MEDIA_ICON_NAME              = 'media.icon_name';

{** For streams: logic role of this media. One of the strings 'video', 'music', 'game', 'event', 'phone', 'animation', 'production', 'a11y', 'test' *}
  PA_PROP_MEDIA_ROLE                   = 'media.role';

{** For streams: the name of a filter that is desired, e.g.\ 'echo-cancel' or 'equalizer-sink'. PulseAudio may choose to not apply the filter if it does not make sense (for example, applying echo-cancellation on a Bluetooth headset probably does not make sense. \since 1.0 *}
  PA_PROP_FILTER_WANT                  = 'filter.want';

{** For streams: the name of a filter that is desired, e.g.\ 'echo-cancel' or 'equalizer-sink'. Differs from PA_PROP_FILTER_WANT in that it forces PulseAudio to apply the filter, regardless of whether PulseAudio thinks it makes sense to do so or not. If this is set, PA_PROP_FILTER_WANT is ignored. In other words, you almost certainly do not want to use this. \since 1.0 *}
  PA_PROP_FILTER_APPLY                 = 'filter.apply';

{** For streams: the name of a filter that should specifically suppressed (i.e.\ overrides PA_PROP_FILTER_WANT). Useful for the times that PA_PROP_FILTER_WANT is automatically added (e.g. echo-cancellation for phone streams when $VOIP_APP does it's own, internal AEC) \since 1.0 *}
  PA_PROP_FILTER_SUPPRESS              = 'filter.suppress';

{** For event sound streams: XDG event sound name. e.g.\ 'message-new-email' (Event sound streams are those with media.role set to 'event') *}
  PA_PROP_EVENT_ID                     = 'event.id';

{** For event sound streams: localized human readable one-line description of the event, formatted as UTF-8. E.g. 'Email from lennart@example.com received.' *}
  PA_PROP_EVENT_DESCRIPTION            = 'event.description';

{** For event sound streams: absolute horizontal mouse position on the screen if the event sound was triggered by a mouse click, integer formatted as text string. E.g. '865' *}
  PA_PROP_EVENT_MOUSE_X                = 'event.mouse.x';

{** For event sound streams: absolute vertical mouse position on the screen if the event sound was triggered by a mouse click, integer formatted as text string. E.g. '432' *}
  PA_PROP_EVENT_MOUSE_Y                = 'event.mouse.y';

{** For event sound streams: relative horizontal mouse position on the screen if the event sound was triggered by a mouse click, float formatted as text string, ranging from 0.0 (left side of the screen) to 1.0 (right side of the screen). E.g. '0.65' *}
  PA_PROP_EVENT_MOUSE_HPOS             = 'event.mouse.hpos';

{** For event sound streams: relative vertical mouse position on the screen if the event sound was triggered by a mouse click, float formatted as text string, ranging from 0.0 (top of the screen) to 1.0 (bottom of the screen). E.g. '0.43' *}
  PA_PROP_EVENT_MOUSE_VPOS             = 'event.mouse.vpos';

{** For event sound streams: mouse button that triggered the event if applicable, integer formatted as string with 0=left, 1=middle, 2=right. E.g. '0' *}
  PA_PROP_EVENT_MOUSE_BUTTON           =  'event.mouse.button';

{** For streams that belong to a window on the screen: localized window title. E.g. 'Totem Music Player' *}
  PA_PROP_WINDOW_NAME                  = 'window.name';

{** For streams that belong to a window on the screen: a textual id for identifying a window logically. E.g. 'org.gnome.Totem.MainWindow' *}
  PA_PROP_WINDOW_ID                    = 'window.id';

{** For streams that belong to a window on the screen: window icon. A binary blob containing PNG image data *}
  PA_PROP_WINDOW_ICON                  = 'window.icon';

{** For streams that belong to a window on the screen: an XDG icon name for the window. E.g. 'totem' *}
  PA_PROP_WINDOW_ICON_NAME             = 'window.icon_name';

{** For streams that belong to a window on the screen: absolute horizontal window position on the screen, integer formatted as text string. E.g. '865'. \since 0.9.17 *}
  PA_PROP_WINDOW_X                     = 'window.x';

{** For streams that belong to a window on the screen: absolute vertical window position on the screen, integer formatted as text string. E.g. '343'. \since 0.9.17 *}
  PA_PROP_WINDOW_Y                     = 'window.y';

{** For streams that belong to a window on the screen: window width on the screen, integer formatted as text string. e.g. '365'. \since 0.9.17 *}
  PA_PROP_WINDOW_WIDTH                 = 'window.width';

{** For streams that belong to a window on the screen: window height on the screen, integer formatted as text string. E.g. '643'. \since 0.9.17 *}
  PA_PROP_WINDOW_HEIGHT                = 'window.height';

{** For streams that belong to a window on the screen: relative position of the window center on the screen, float formatted as text string, ranging from 0.0 (left side of the screen) to 1.0 (right side of the screen). E.g. '0.65'. \since 0.9.17 *}
  PA_PROP_WINDOW_HPOS                  = 'window.hpos';

{** For streams that belong to a window on the screen: relative position of the window center on the screen, float formatted as text string, ranging from 0.0 (top of the screen) to 1.0 (bottom of the screen). E.g. '0.43'. \since 0.9.17 *}
  PA_PROP_WINDOW_VPOS                  = 'window.vpos';

{** For streams that belong to a window on the screen: if the windowing system supports multiple desktops, a comma separated list of indexes of the desktops this window is visible on. If this property is an empty string, it is visible on all desktops (i.e. 'sticky'). The first desktop is 0. E.g. '0,2,3' \since 0.9.18 *}
  PA_PROP_WINDOW_DESKTOP               = 'window.desktop';

{** For streams that belong to an X11 window on the screen: the X11 display string. E.g. ':0.0' *}
  PA_PROP_WINDOW_X11_DISPLAY           = 'window.x11.display';

{** For streams that belong to an X11 window on the screen: the X11 screen the window is on, an integer formatted as string. E.g. '0' *}
  PA_PROP_WINDOW_X11_SCREEN            = 'window.x11.screen';

{** For streams that belong to an X11 window on the screen: the X11 monitor the window is on, an integer formatted as string. E.g. '0' *}
  PA_PROP_WINDOW_X11_MONITOR           = 'window.x11.monitor';

{** For streams that belong to an X11 window on the screen: the window XID, an integer formatted as string. E.g. '25632' *}
  PA_PROP_WINDOW_X11_XID               = 'window.x11.xid';

{** For clients/streams: localized human readable application name. E.g. 'Totem Music Player' *}
  PA_PROP_APPLICATION_NAME             = 'application.name';

{** For clients/streams: a textual id for identifying an application logically. E.g. 'org.gnome.Totem' *}
  PA_PROP_APPLICATION_ID               = 'application.id';

{** For clients/streams: a version string, e.g.\ '0.6.88' *}
  PA_PROP_APPLICATION_VERSION          = 'application.version';

{** For clients/streams: application icon. A binary blob containing PNG image data *}
  PA_PROP_APPLICATION_ICON             = 'application.icon';

{** For clients/streams: an XDG icon name for the application. E.g. 'totem' *}
  PA_PROP_APPLICATION_ICON_NAME        = 'application.icon_name';

{** For clients/streams: application language if applicable, in standard POSIX format. E.g. 'de_DE' *}
  PA_PROP_APPLICATION_LANGUAGE         = 'application.language';

{** For clients/streams on UNIX: application process PID, an integer formatted as string. E.g. '4711' *}
  PA_PROP_APPLICATION_PROCESS_ID       = 'application.process.id';

{** For clients/streams: application process name. E.g. 'totem' *}
  PA_PROP_APPLICATION_PROCESS_BINARY   = 'application.process.binary';

{** For clients/streams: application user name. E.g. 'lennart' *}
  PA_PROP_APPLICATION_PROCESS_USER     = 'application.process.user';

{** For clients/streams: host name the application runs on. E.g. 'omega' *}
  PA_PROP_APPLICATION_PROCESS_HOST     = 'application.process.host';

{** For clients/streams: the D-Bus host id the application runs on. E.g. '543679e7b01393ed3e3e650047d78f6e' *}
  PA_PROP_APPLICATION_PROCESS_MACHINE_ID='application.process.machine_id';

{** For clients/streams: an id for the login session the application runs in. On Unix the value of $XDG_SESSION_ID. E.g. '5' *}
  PA_PROP_APPLICATION_PROCESS_SESSION_ID='application.process.session_id';

{** For devices: device string in the underlying audio layer's format. E.g. 'surround51:0' *}
  PA_PROP_DEVICE_STRING                = 'device.string';

{** For devices: API this device is access with. E.g. 'alsa' *}
  PA_PROP_DEVICE_API                   = 'device.api';

{** For devices: localized human readable device one-line description. E.g. 'Foobar Industries USB Headset 2000+ Ultra' *}
  PA_PROP_DEVICE_DESCRIPTION           = 'device.description';

{** For devices: bus path to the device in the OS' format. E.g. '/sys/bus/pci/devices/0000:00:1f.2' *}
  PA_PROP_DEVICE_BUS_PATH              = 'device.bus_path';

{** For devices: serial number if applicable. E.g. '4711-0815-1234' *}
  PA_PROP_DEVICE_SERIAL                = 'device.serial';

{** For devices: vendor ID if applicable. E.g. 1274 *}
  PA_PROP_DEVICE_VENDOR_ID             = 'device.vendor.id';

{** For devices: vendor name if applicable. E.g. 'Foocorp Heavy Industries' *}
  PA_PROP_DEVICE_VENDOR_NAME           = 'device.vendor.name';

{** For devices: product ID if applicable. E.g. 4565 *}
  PA_PROP_DEVICE_PRODUCT_ID            = 'device.product.id';

{** For devices: product name if applicable. E.g. 'SuperSpeakers 2000 Pro' *}
  PA_PROP_DEVICE_PRODUCT_NAME          = 'device.product.name';

{** For devices: device class. One of 'sound', 'modem', 'monitor', 'filter' *}
  PA_PROP_DEVICE_CLASS                 = 'device.class';

{** For devices: form factor if applicable. One of 'internal', 'speaker', 'handset', 'tv', 'webcam', 'microphone', 'headset', 'headphone', 'hands-free', 'car', 'hifi', 'computer', 'portable' *}
  PA_PROP_DEVICE_FORM_FACTOR           = 'device.form_factor';

{** For devices: bus of the device if applicable. One of 'isa', 'pci', 'usb', 'firewire', 'bluetooth' *}
  PA_PROP_DEVICE_BUS                   = 'device.bus';

{** For devices: icon for the device. A binary blob containing PNG image data *}
  PA_PROP_DEVICE_ICON                  = 'device.icon';

{** For devices: an XDG icon name for the device. E.g. 'sound-card-speakers-usb' *}
  PA_PROP_DEVICE_ICON_NAME             = 'device.icon_name';

{** For devices: access mode of the device if applicable. One of 'mmap', 'mmap_rewrite', 'serial' *}
  PA_PROP_DEVICE_ACCESS_MODE           = 'device.access_mode';

{** For filter devices: master device id if applicable. *}
  PA_PROP_DEVICE_MASTER_DEVICE         = 'device.master_device';

{** For devices: buffer size in bytes, integer formatted as string. *}
  PA_PROP_DEVICE_BUFFERING_BUFFER_SIZE = 'device.buffering.buffer_size';

{** For devices: fragment size in bytes, integer formatted as string. *}
  PA_PROP_DEVICE_BUFFERING_FRAGMENT_SIZE='device.buffering.fragment_size';

{** For devices: profile identifier for the profile this devices is in. E.g. 'analog-stereo', 'analog-surround-40', 'iec958-stereo', ...*}
  PA_PROP_DEVICE_PROFILE_NAME          = 'device.profile.name';

{** For devices: intended use. A space separated list of roles (see PA_PROP_MEDIA_ROLE) this device is particularly well suited for, due to latency, quality or form factor. \since 0.9.16 *}
  PA_PROP_DEVICE_INTENDED_ROLES        = 'device.intended_roles';

{** For devices: human readable one-line description of the profile this device is in. E.g. 'Analog Stereo', ... *}
  PA_PROP_DEVICE_PROFILE_DESCRIPTION   = 'device.profile.description';

{** For modules: the author's name, formatted as UTF-8 string. E.g. 'Lennart Poettering' *}
  PA_PROP_MODULE_AUTHOR                = 'module.author';

{** For modules: a human readable one-line description of the module's purpose formatted as UTF-8. E.g. 'Frobnicate sounds with a flux compensator' *}
  PA_PROP_MODULE_DESCRIPTION           = 'module.description';

{** For modules: a human readable usage description of the module's arguments formatted as UTF-8. *}
  PA_PROP_MODULE_USAGE                 = 'module.usage';

{** For modules: a version string for the module. E.g. '0.9.15' *}
  PA_PROP_MODULE_VERSION               = 'module.version';

{** For PCM formats: the sample format used as returned by pa_sample_format_to_string() \since 1.0 *}
  PA_PROP_FORMAT_SAMPLE_FORMAT         = 'format.sample_format';

{** For all formats: the sample rate (unsigned integer) \since 1.0 *}
  PA_PROP_FORMAT_RATE                  = 'format.rate';

{** For all formats: the number of channels (unsigned integer) \since 1.0 *}
  PA_PROP_FORMAT_CHANNELS              = 'format.channels';

{** For PCM formats: the channel map of the stream as returned by pa_channel_map_snprint() \since 1.0 *}
  PA_PROP_FORMAT_CHANNEL_MAP           = 'format.channel_map';

type

  {** Update mode enum for pa_proplist_update(). \since 0.9.11 *}
  TPAUpdateMode = (
    PA_UPDATE_SET,
    {**< Replace the entire property list with the new one. Don't keep
     *  any of the old data around. *}

    PA_UPDATE_MERGE,
    {**< Merge new property list into the existing one, not replacing
     *  any old entries if they share a common key with the new
     *  property list. *}

    PA_UPDATE_REPLACE
    {**< Merge new property list into the existing one, replacing all
     *  old entries that share a common key with the new property
     *  list. *}
    );

  {** A property list object. Basically a dictionary with ASCII strings
    * as keys and arbitrary data as values. \since 0.9.11 *}
  PPAProplist = ^TPAProplist;

  { TPAProplist }

  TPAProplist = object {sealed}
    function  New: PPAProplist; static;
    function  NewFromString(AString: PChar): PPAProplist; static;
    procedure Free;
    function  KeyValid(AKey: PChar): Boolean static;
    function  SetString(AKey, AValue: PChar): cint;
    function  SetPair(APair: PChar): cint; // 'akey=avalue';
    //function  SetFormat(AKey, AFormat: PChar): cint; varargs;
    function  Set_(AKey: PChar; AData: Pointer; ASize: csize_t): cint;
    function Get(AKey: PChar; AData: PPointer; ASize: pcsize_t): cint;
    procedure Update(AMode: TPAUpdateMode; AOther: PPAProplist);
    function  Unset(AKey: PChar): cint;
    function  UnsetMany(Keys: PPChar): cint; // last element must be nil
    function  Iterate(AState: PPointer): pchar;
    function  ToString: PChar;
    function  ToStringWithSeperator(ASeperator: PChar): PChar;
    function  Contains(AKey: PChar): Boolean;
    procedure Clear;
    function  Copy: PPAProplist;
    function  Count: cunsigned;
    function  IsEmpty: Boolean;
    function  Equal(APropList: PPAProplist): Boolean;
  end;

{** Allocate a property list. \since 0.9.11 *}
function pa_proplist_new: PPAProplist external;

{** Free the property list. \since 0.9.11 *}
procedure pa_proplist_free(p: PPAProplist) external;

{** Returns a non-zero value if the key is valid. \since 3.0 *}
function pa_proplist_key_valid(const key: PChar): cint external;

{** Append a new string entry to the property list, possibly
 * overwriting an already existing entry with the same key. An
 * internal copy of the data passed is made. Will accept only valid
 * UTF-8. \since 0.9.11 *}
function pa_proplist_sets(p: PPAProplist; key: pchar; value: pchar): cint external;

{** Append a new string entry to the property list, possibly
 * overwriting an already existing entry with the same key. An
 * internal copy of the data passed is made. Will accept only valid
 * UTF-8. The string passed in must contain a '='. Left hand side of
 * the '=' is used as key name, the right hand side as string
 * data. \since 0.9.16 *}
function pa_proplist_setp(p: PPAProplist; pair: pchar): cint external;

{** Append a new string entry to the property list, possibly
 * overwriting an already existing entry with the same key. An
 * internal copy of the data passed is made. Will accept only valid
 * UTF-8. The data can be passed as printf()-style format string with
 * arguments. \since 0.9.11 *}
function pa_proplist_setf(p: PPAProplist; key: pchar; format: pchar): cint varargs external;

{** Append a new arbitrary data entry to the property list, possibly
 * overwriting an already existing entry with the same key. An
 * internal copy of the data passed is made. \since 0.9.11 *}
function pa_proplist_set(p: PPAProplist; key: pchar; data: pointer; bytes: csize_t): cint external;

{** Return a string entry for the specified key. Will return NULL if
 * the data is not valid UTF-8. Will return a NUL-terminated string in
 * an internally allocated buffer. The caller should make a copy of
 * the data before accessing the property list again. \since 0.9.11 *}
function pa_proplist_gets(p: PPAProplist; key: pchar): pchar external;

{** Store the value for the specified key in \a data. Will store a
 * NUL-terminated string for string entries. The \a data pointer returned will
 * point to an internally allocated buffer. The caller should make a
 * copy of the data before the property list is accessed again. \since
 * 0.9.11 *}
function pa_proplist_get(p: PPAProplist; key: pchar; data: PPointer; nbytes: pcsize_t): cint external;

{** Merge property list "other" into "p", adhering the merge mode as
 * specified in "mode". \since 0.9.11 *}
procedure pa_proplist_update(p: PPAProplist; mode: TPAUpdateMode; other: PPAProplist) external;

{** Removes a single entry from the property list, identified be the
 * specified key name. \since 0.9.11 *}
function pa_proplist_unset(p: PPAProplist; key: PChar): cint external;

{** Similar to pa_proplist_unset() but takes an array of keys to
 * remove. The array should be terminated by a NULL pointer. Returns -1
 * on failure, otherwise the number of entries actually removed (which
 * might even be 0, if there were no matching entries to
 * remove). \since 0.9.11 *}
function pa_proplist_unset_many(p: PPAProplist; keys: PPChar): cint external;

{** Iterate through the property list. The user should allocate a
 * state variable of type void* and initialize it with NULL. A pointer
 * to this variable should then be passed to pa_proplist_iterate()
 * which should be called in a loop until it returns NULL which
 * signifies EOL. The property list should not be modified during
 * iteration through the list -- with the exception of deleting the
 * current entry. On each invocation this function will return the
 * key string for the next entry. The keys in the property list do not
 * have any particular order. \since 0.9.11 *}
function pa_proplist_iterate(p: PPAProplist; state: PPointer): PChar external;

{** Format the property list nicely as a human readable string. This
 * works very much like pa_proplist_to_string_sep() and uses a newline
 * as separator and appends one final one. Call pa_xfree() on the
 * result. \since 0.9.11 *}
function pa_proplist_to_string(p: PPAProplist): PChar external;

{** Format the property list nicely as a human readable string and
 * choose the separator. Call pa_xfree() on the result. \since
 * 0.9.15 *}
function pa_proplist_to_string_sep(p: PPAProplist; sep: PChar): PChar external;

{** Allocate a new property list and assign key/value from a human
 * readable string. \since 0.9.15 *}
function pa_proplist_from_string(str: PChar): PPAProplist external;

{** Returns 1 if an entry for the specified key exists in the
 * property list. \since 0.9.11 *}
function pa_proplist_contains(p: PPAProplist; key: PChar): cint external;

{** Remove all entries from the property list object. \since 0.9.11 *}
procedure pa_proplist_clear(p: PPAProplist) external;

{** Allocate a new property list and copy over every single entry from
 * the specified list. \since 0.9.11 *}
function pa_proplist_copy(p: PPAProplist): PPAProplist external;

{** Return the number of entries in the property list. \since 0.9.15 *}
function pa_proplist_size(p: PPAProplist): cunsigned external;

{** Returns 0 when the proplist is empty, positive otherwise \since 0.9.15 *}
function pa_proplist_isempty(p: PPAProplist): cint external;

{** Return non-zero when a and b have the same keys and values.
 * \since 0.9.16 *}
function pa_proplist_equal(a: PPAProplist; b: PPAProplist): cint external;
implementation

{ TPAProplist }

function TPAProplist.New: PPAProplist;
begin
  Result := pa_proplist_new;
end;

function TPAProplist.NewFromString(AString: PChar): PPAProplist;
begin
  Result := pa_proplist_from_string(AString);
end;

procedure TPAProplist.Free;
begin
  pa_proplist_free(@self);
end;

function TPAProplist.KeyValid(AKey: PChar): Boolean;
begin
  Result := pa_proplist_key_valid(AKey) <> 0;
end;

function TPAProplist.SetString(AKey, AValue: PChar): cint;
begin
 Result := pa_proplist_sets(@self, AKey, AValue);
end;

function TPAProplist.SetPair(APair: PChar): cint;
begin
  Result := pa_proplist_setp(@self, APair);
end;

function TPAProplist.Set_(AKey: PChar; AData: Pointer; ASize: csize_t): cint;
begin
  Result := pa_proplist_set(@self, AKey, AData, ASize);
end;

function TPAProplist.Get(AKey: PChar; AData: PPointer; ASize: pcsize_t): cint;
begin
  Result := pa_proplist_get(@self, AKey, AData, ASize);
end;

procedure TPAProplist.Update(AMode: TPAUpdateMode; AOther: PPAProplist);
begin
  pa_proplist_update(@self, AMode, AOther);
end;

function TPAProplist.Unset(AKey: PChar): cint;
begin
  Result := pa_proplist_unset(@Self, AKey);
end;

function TPAProplist.UnsetMany(Keys: PPChar): cint;
begin
  Result := pa_proplist_unset_many(@self, Keys);
end;

function TPAProplist.Iterate(AState: PPointer): pchar;
begin
  Result := pa_proplist_iterate(@self, AState);
end;

function TPAProplist.ToString: PChar;
begin
  Result := pa_proplist_to_string(@self);
end;

function TPAProplist.ToStringWithSeperator(ASeperator: PChar): PChar;
begin
  Result := pa_proplist_to_string_sep(@self, ASeperator);
end;

function TPAProplist.Contains(AKey: PChar): Boolean;
begin
  Result := pa_proplist_contains(@self, AKey) = 1;
end;

procedure TPAProplist.Clear;
begin
  pa_proplist_clear(@self);
end;

function TPAProplist.Copy: PPAProplist;
begin
  Result := pa_proplist_copy(@Self);
end;

function TPAProplist.Count: cunsigned;
begin
  Result := pa_proplist_size(@self);
end;

function TPAProplist.IsEmpty: Boolean;
begin
  // returns positive number when not empty
  Result := pa_proplist_isempty(@self) = 0;
end;

function TPAProplist.Equal(APropList: PPAProplist): Boolean;
begin
  Result := pa_proplist_equal(@self, APropList) <> 0;
end;

end.

