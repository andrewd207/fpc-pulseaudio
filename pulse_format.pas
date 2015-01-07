{***
  This file is part of PulseAudio.

  Copyright 2011 Intel Corporation
  Copyright 2011 Collabora Multimedia
  Copyright 2011 Arun Raghavan <arun.raghavan@collabora.co.uk>

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
unit pulse_format;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, pulse_proplist, pulse_sample, pulse_channelmap, ctypes;

type
  TPAEncoding = (
    {**< Represents an invalid encoding *}
    PA_ENCODING_INVALID = -1,
    {**< Any encoding format, PCM or compressed *}
    PA_ENCODING_ANY,
    {**< Any PCM format *}
    PA_ENCODING_PCM,
    {**< AC3 data encapsulated in IEC 61937 header/padding *}
    PA_ENCODING_AC3_IEC61937,
    {**< EAC3 data encapsulated in IEC 61937 header/padding *}
    PA_ENCODING_EAC3_IEC61937,
    {**< MPEG-1 or MPEG-2 (Part 3, not AAC) data encapsulated in IEC 61937 header/padding *}
    PA_ENCODING_MPEG_IEC61937,
    {**< DTS data encapsulated in IEC 61937 header/padding *}
    PA_ENCODING_DTS_IEC61937,
    {**< MPEG-2 AAC data encapsulated in IEC 61937 header/padding. \since 4.0 *}
    PA_ENCODING_MPEG2_AAC_IEC61937,
    {**< Valid encoding types must be less than this value *}
    PA_ENCODING_MAX
    );

  {** Returns a printable string representing the given encoding type. \since 1.0 *}
function pa_encoding_to_string(e: TPAEncoding) : PChar external;

{** Converts a string of the form returned by \a pa_encoding_to_string() back to a \a TPAEncoding. \since 1.0 *}
function pa_encoding_from_string(encoding: pchar): TPAEncoding external;

type
{** Represents the type of value type of a property on a \ref pa_format_info. \since 2.0 *}
  TPAPropType = (
    {**< Represents an invalid type *}
    PA_PROP_TYPE_INVALID = -1,
    {**< Integer property *}
    PA_PROP_TYPE_INT,
    {**< Integer range property *}
    PA_PROP_TYPE_INT_RANGE,
    {**< Integer array property *}
    PA_PROP_TYPE_INT_ARRAY,
    {**< String property *}
    PA_PROP_TYPE_STRING,
    {**< String array property *}
    PA_PROP_TYPE_STRING_ARRAY
    );

type
  ppcint = ^pcint;
  {** Represents the format of data provided in a stream or processed by a sink. \since 1.0 *}
  PPPAFormatInfo = ^PPAFormatInfo;
  PPAFormatInfo = ^ TPAFormatInfo;

  { TPAFormatInfo }

  TPAFormatInfo = object sealed
    {**< The encoding used for the format *}
    encoding: TPAEncoding ;
    {**< Additional encoding-specific properties such as sample rate, bitrate, etc. *}
    plist: PPAProplist;
    function  New: PPAFormatInfo; static;
    function  NewFromString(AString: PChar): PPAFormatInfo; static;
    function  NewFromSampleSpec(ASampleSpec: PPASampleSpec; AMap: PPAChannelMap): PPAFormatInfo; static;
    function  Copy: PPAFormatInfo;
    procedure Free;
    function  Valid: Boolean;
    function  IsPCM: Boolean;
    function  IsCompatible(AFormatInfo: PPAFormatInfo): Boolean;
    function  snprintf(s: PChar; l: csize_t): PChar;
    function  GetPropType(AKey: PChar): TPAPropType;
    function  GetPropInt(AKey: PChar; AValue: pcint): cint;
    function  GetPropIntRange(AKey: PChar; AMin, AMax: pcint): cint;
    function  GetPropIntArray(AKey: PChar; Values: ppcint; AValueCount: pcint): cint;
    function  GetPropString(AKey: PChar; AValue: PPChar): cint;
    function  GetPropStringArray(AKey: PChar; Values: pppchar; AValueCount: pcint): cint;
    procedure SetSampleFormat(ASampleFormat: TPASampleFormat);
    procedure SetSampleRate(ASampleRate: cint);
    procedure SetChannels(AChannels: cint);
    procedure SetChannelMap(AMap: PPAChannelMap);


  end;

{** Allocates a new \a pa_format_info structure. Clients must initialise at least the encoding field themselves. \since 1.0 *}
function pa_format_info_new: PPAFormatInfo external;

{** Returns a new \a pa_format_info struct and representing the same format as \a src. \since 1.0 *}
function pa_format_info_copy({const} src: PPAFormatInfo): PPAFormatInfo external;

{** Frees a \a pa_format_info structure. \since 1.0 *}
procedure pa_format_info_free(f: PPAFormatInfo) external;

{** Returns non-zero when the format info structure is valid. \since 1.0 *}
function pa_format_info_valid({const} f: PPAFormatInfo): cint external;

{** Returns non-zero when the format info structure represents a PCM (i.e.\ uncompressed data) format. \since 1.0 *}
function pa_format_info_is_pcm({const} f: PPAFormatInfo): cint external;

{** Returns non-zero if the format represented by \a first is a subset of
 * the format represented by \a second. This means that \a second must
 * have all the fields that \a first does, but the reverse need not
 * be true. This is typically expected to be used to check if a
 * stream's format is compatible with a given sink. In such a case,
 * \a first would be the sink's format and \a second would be the
 * stream's. \since 1.0 *}
function pa_format_info_is_compatible({const} first: PPAFormatInfo; {const} second: PPAFormatInfo): cint external;

{** Maximum required string length for
 * pa_format_info_snprint(). Please note that this value can change
 * with any release without warning and without being considered API
 * or ABI breakage. You should not use this definition anywhere where
 * it might become part of an ABI. \since 1.0 *}
const
  PA_FORMAT_INFO_SNPRINT_MAX = 256;

{** Return a human-readable string representing the given format. \since 1.0 *}
function pa_format_info_snprint(s: pchar; l: csize_t; {const} f: PPAFormatInfo): PChar external;

{** Parse a human-readable string of the form generated by
 * \a pa_format_info_snprint() into a pa_format_info structure. \since 1.0 *}
function  pa_format_info_from_string({const} str: PChar): PPAFormatInfo external;

{** Utility function to take a \a pa_sample_spec and generate the corresponding
 * \a pa_format_info.
 *
 * Note that if you want the server to choose some of the stream parameters,
 * for example the sample rate, so that they match the device parameters, then
 * you shouldn't use this function. In order to allow the server to choose
 * a parameter value, that parameter must be left unspecified in the
 * pa_format_info object, and this function always specifies all parameters. An
 * exception is the channel map: if you pass NULL for the channel map, then the
 * channel map will be left unspecified, allowing the server to choose it.
 *
 * \since 2.0 *}
function pa_format_info_from_sample_spec({const} ss: PPASampleSpec; {const} map: PPAChannelMap): PPAFormatInfo external;

{** Utility function to generate a \a pa_sample_spec and \a pa_channel_map corresponding to a given \a pa_format_info. The
 * conversion for PCM formats is straight-forward. For non-PCM formats, if there is a fixed size-time conversion (i.e. all
 * IEC61937-encapsulated formats), a "fake" sample spec whose size-time conversion corresponds to this format is provided and
 * the channel map argument is ignored. For formats with variable size-time conversion, this function will fail. Returns a
 * negative integer if conversion failed and 0 on success. \since 2.0 *}
function pa_format_info_to_sample_spec({const} f: PPAFormatInfo; ss: PPASampleSpec; map: PPAChannelMap): cint external;


{** Gets the type of property \a key in a given \ref pa_format_info. \since 2.0 *}
function pa_format_info_get_prop_type({const} f: PPAFormatInfo; {const} key: PChar): TPAPropType external;

{** Gets an integer property from the given format info. Returns 0 on success and a negative integer on failure. \since 2.0 *}
function pa_format_info_get_prop_int({const} f: PPAFormatInfo; {const} key: PChar; v: pcint): cint external;
{** Gets an integer range property from the given format info. Returns 0 on success and a negative integer on failure.
 * \since 2.0 *}
function pa_format_info_get_prop_int_range({const} f: PPAFormatInfo; {const} key: pchar; min, max: pcint): cint external;
{** Gets an integer array property from the given format info. \a values contains the values and \a n_values contains the
 * number of elements. The caller must free \a values using \ref pa_xfree. Returns 0 on success and a negative integer on
 * failure. \since 2.0 *}
function pa_format_info_get_prop_int_array({const} f: PPAFormatInfo; {const} key: pchar; values: ppcint; n_values: pcint): cint external;
{** Gets a string property from the given format info.  The caller must free the returned string using \ref pa_xfree. Returns
 * 0 on success and a negative integer on failure. \since 2.0 *}
function pa_format_info_get_prop_string({const} f: PPAFormatInfo; {const} key: pchar; v: ppchar): cint external;
{** Gets a string array property from the given format info. \a values contains the values and \a n_values contains
 * the number of elements. The caller must free \a values using \ref pa_format_info_free_string_array. Returns 0 on success and
 * a negative integer on failure. \since 2.0 *}
function pa_format_info_get_prop_string_array({const} f: PPAFormatInfo; {const} key: pchar; values: PPPChar; n_values: pcint): cint external;

{** Frees a string array returned by \ref pa_format_info_get_prop_string_array. \since 2.0 *}
procedure pa_format_info_free_string_array(values: PPChar; n_values: cint) external;

{** Sets an integer property on the given format info. \since 1.0 *}
procedure pa_format_info_set_prop_int(f: PPAFormatInfo; {const} key: pchar; value: cint) external;
{** Sets a property with a list of integer values on the given format info. \since 1.0 *}
procedure pa_format_info_set_prop_int_array(f: PPAFormatInfo; {const} key: pchar; {const} values: pcint; n_values: cint) external;
{** Sets a property which can have any value in a given integer range on the given format info. \since 1.0 *}
procedure pa_format_info_set_prop_int_range(f: PPAFormatInfo; {const} key: pchar; min,max: cint) external;
{** Sets a string property on the given format info. \since 1.0 *}
procedure pa_format_info_set_prop_string(f: PPAFormatInfo; {const} key: pchar; {const} value: pchar) external;
{** Sets a property with a list of string values on the given format info. \since 1.0 *}
procedure pa_format_info_set_prop_string_array(f: PPAFormatInfo; {const} key: pchar; {const} values: ppchar; n_values: cint) external;

{** Convenience method to set the sample format as a property on the given
 * format.
 *
 * Note for PCM: If the sample format is left unspecified in the pa_format_info
 * object, then the server will select the stream sample format. In that case
 * the stream sample format will most likely match the device sample format,
 * meaning that sample format conversion will be avoided.
 *
 * \since 1.0 *}
procedure pa_format_info_set_sample_format(f: PPAFormatInfo; sf: TPASampleFormat) external;

{** Convenience method to set the sampling rate as a property on the given
 * format.
 *
 * Note for PCM: If the sample rate is left unspecified in the pa_format_info
 * object, then the server will select the stream sample rate. In that case the
 * stream sample rate will most likely match the device sample rate, meaning
 * that sample rate conversion will be avoided.
 *
 * \since 1.0 *}
procedure pa_format_info_set_rate(f: PPAFormatInfo; rate: cint) external;

{** Convenience method to set the number of channels as a property on the given
 * format.
 *
 * Note for PCM: If the channel count is left unspecified in the pa_format_info
 * object, then the server will select the stream channel count. In that case
 * the stream channel count will most likely match the device channel count,
 * meaning that up/downmixing will be avoided.
 *
 * \since 1.0 *}
procedure pa_format_info_set_channels(f: PPAFormatInfo; channels: cint) external;

{** Convenience method to set the channel map as a property on the given
 * format.
 *
 * Note for PCM: If the channel map is left unspecified in the pa_format_info
 * object, then the server will select the stream channel map. In that case the
 * stream channel map will most likely match the device channel map, meaning
 * that remixing will be avoided.
 *
 * \since 1.0 *}
procedure pa_format_info_set_channel_map(f: PPAFormatInfo; {const} map: PPAChannelMap) external;

implementation

{ TPAFormatInfo }

function TPAFormatInfo.New: PPAFormatInfo;
begin
  Result := pa_format_info_new;
end;

function TPAFormatInfo.NewFromString(AString: PChar): PPAFormatInfo;
begin
  Result := pa_format_info_from_string(AString);
end;

function TPAFormatInfo.NewFromSampleSpec(ASampleSpec: PPASampleSpec;
  AMap: PPAChannelMap): PPAFormatInfo;
begin
  Result := pa_format_info_from_sample_spec(ASampleSpec, AMap);
end;

function TPAFormatInfo.Copy: PPAFormatInfo;
begin
  Result := pa_format_info_copy(@self);
end;

procedure TPAFormatInfo.Free;
begin
  pa_format_info_free(@self);
end;

function TPAFormatInfo.Valid: Boolean;
begin
  Result := pa_format_info_valid(@self) <> 0;
end;

function TPAFormatInfo.IsPCM: Boolean;
begin
  Result := pa_format_info_is_pcm(@self) <> 0;
end;

function TPAFormatInfo.IsCompatible(AFormatInfo: PPAFormatInfo): Boolean;
begin
  Result := pa_format_info_is_compatible(@self, AFormatInfo) <> 0;
end;

function TPAFormatInfo.snprintf(s: PChar; l: csize_t): PChar;
begin
  Result := pa_format_info_snprint(s,l,@self);
end;

function TPAFormatInfo.GetPropType(AKey: PChar): TPAPropType;
begin
  Result := pa_format_info_get_prop_type(@self, AKey);
end;

function TPAFormatInfo.GetPropInt(AKey: PChar; AValue: pcint): cint;
begin
  Result := pa_format_info_get_prop_int(@self, AKey, AValue);
end;

function TPAFormatInfo.GetPropIntRange(AKey: PChar; AMin, AMax: pcint): cint;
begin
  Result := pa_format_info_get_prop_int_range(@self, AKey, AMin, AMax);
end;

function TPAFormatInfo.GetPropIntArray(AKey: PChar; Values: ppcint; AValueCount: pcint): cint;
begin
  Result := pa_format_info_get_prop_int_array(@self, AKey, Values, AValueCount);
end;

function TPAFormatInfo.GetPropString(AKey: PChar; AValue: PPChar): cint;
begin
  Result := pa_format_info_get_prop_string(@self, AKey, AValue);
end;

function TPAFormatInfo.GetPropStringArray(AKey: PChar; Values: pppchar; AValueCount: pcint): cint;
begin
  Result := pa_format_info_get_prop_string_array(@self, AKey, Values, AValueCount);
end;

procedure TPAFormatInfo.SetSampleFormat(ASampleFormat: TPASampleFormat);
begin
  pa_format_info_set_sample_format(@self, ASampleFormat);
end;

procedure TPAFormatInfo.SetSampleRate(ASampleRate: cint);
begin
  pa_format_info_set_rate(@self, ASampleRate);
end;

procedure TPAFormatInfo.SetChannels(AChannels: cint);
begin
  pa_format_info_set_channels(@self, AChannels);
end;

procedure TPAFormatInfo.SetChannelMap(AMap: PPAChannelMap);
begin
  pa_format_info_set_channel_map(@self, AMap);
end;

end.

