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
unit pulse_sample;

{$mode objfpc}{$H+}
{$PACKRECORDS C}
{$CALLING CDECL}

{$linklib pulse}

interface

uses
  Classes, SysUtils, ctypes;

const
  // Maximum number of allowed channels
  PA_CHANNELS_MAX = 32;

  // Maximum allowed sample rate
  PA_RATE_MAX = (48000*4);

type
  TPASampleFormat = (
    // An invalid value
    sfInvalid = -1,
    // Unsigned 8 Bit PCM
    sfU8,
    // 8 Bit a-Law
    sfALaw,
    // 8 Bit mu-Law
    sfULaw,
    // Signed 16 Bit PCM, little endian (PC)
    sfS16LE,
    // Signed 16 Bit PCM, big endian
    sfS16BE,
    // 32 Bit IEEE floating point, little endian (PC), range -1.0 to 1.0
    sfFloat32LE,
    // 32 Bit IEEE floating point, big endian, range -1.0 to 1.0
    sfFloat32BE,
    // Signed 32 Bit PCM, little endian (PC)
    sfS32LE,
    // Signed 32 Bit PCM, big endian
    sfS32BE,
    // Signed 24 Bit PCM packed, little endian (PC). \since 0.9.15
    sfS24LE,
    // Signed 24 Bit PCM packed, big endian. \since 0.9.15
    sfS24BE,
    // Signed 24 Bit PCM in LSB of 32 Bit words, little endian (PC). \since 0.9.15
    sfS24_32LE,
    // Signed 24 Bit PCM in LSB of 32 Bit words, big endian. \since 0.9.15
    sfS24_32BE,
    // Upper limit of valid sample types
    sfMax);

  // A sample format and attribute specification
  PPASampleSpec = ^TPASampleSpec;

  { TPASampleSpec }

  TPASampleSpec = object sealed
    // The sample format
    Format: TPASampleFormat;
    // The sample rate. (e.g. 44100)
    Rate: LongWord; //32 unsigned
    // Audio channels. (1 for mono, 2 for stereo, ...)
    Channels: Byte;

    function BytesPerSecond: csize_t;
    function SampleSize: csize_t;
    function BytesToUSec(Length: QWord): QWord;
    function USecToBytes(t: QWord): csize_t;
    function Valid: Boolean;
    function Equal(Spec: PPASampleSpec): Boolean;
    function snprint(s: PChar; l: csize_t): PChar;
    procedure Init;
  end;

// Return the amount of bytes playback of a second of audio with the specified sample type takes */
function pa_bytes_per_second({const} spec: PPASampleSpec): csize_t  external;

// Return the size of a frame with the specific sample type */
function pa_frame_size({const} spec: PPASampleSpec): csize_t external;

// Return the size of a sample with the specific sample type */
function pa_sample_size({const} spec: PPASampleSpec):csize_t external;

// Similar to pa_sample_size() but take a sample format instead of a
// full sample spec. \since 0.9.15
function pa_sample_size_of_format(f: TPASampleFormat): csize_t external;

// Calculate the time the specified bytes take to play with the
// specified sample type. The return value will always be rounded
// down for non-integral return values.
function pa_bytes_to_usec(length: QWord; {const} spec: PPASampleSpec): QWord external;

// Calculates the number of bytes that are required for the specified
// time. The return value will always be rounded down for non-integral
// return values. \since 0.9 */
function pa_usec_to_bytes(t: QWord; {const} spec: PPASampleSpec): csize_t external;

// Initialize the specified sample spec and return a pointer to
// it. The sample spec will have a defined state but
// pa_sample_spec_valid() will fail for it. \since 0.9.13
function pa_sample_spec_init(spec: PPASampleSpec): PPASampleSpec external;

// Return non-zero if the given integer is a valid sample format. \since 5.0 */
function pa_sample_format_valid(format: cunsigned ): cint external;

// Return non-zero if the rate is within the supported range. \since 5.0 */
function pa_sample_rate_valid(rate: LongWord): cint external;

// Return non-zero if the channel count is within the supported range.
// \since 5.0
function pa_channels_valid(channels: byte) : cint external;

// Return non-zero when the sample type specification is valid */
function pa_sample_spec_valid({const} spec: PPASampleSpec): cint external;

// Return non-zero when the two sample type specifications match */
function pa_sample_spec_equal({const} a: PPASampleSpec; {const} b: PPASampleSpec): cint external;

// Return a descriptive string for the specified sample format. \since 0.8 */
function pa_sample_format_to_string(f: TPASampleFormat): PChar external;

// Parse a sample format text. Inverse of pa_sample_format_to_string() */
function pa_parse_sample_format({const} format: PChar): TPASampleFormat external;

{ Maximum required string length for
 * pa_sample_spec_snprint(). Please note that this value can change
 * with any release without warning and without being considered API
 * or ABI breakage. You should not use this definition anywhere where
 * it might become part of an ABI. }
const
 PA_SAMPLE_SPEC_SNPRINT_MAX = 32;

// Pretty print a sample type specification to a string */
function pa_sample_spec_snprint(s: PChar; l: csize_t; {const} spec: PPASampleSpec): PChar external;

{ Maximum required string length for pa_bytes_snprint(). Please note
 * that this value can change with any release without warning and
 * without being considered API or ABI breakage. You should not use
 * this definition anywhere where it might become part of an
 * ABI. \since 0.9.16 }
const
  PA_BYTES_SNPRINT_MAX = 11;

// Pretty print a byte size value (i.e.\ "2.5 MiB") */
function pa_bytes_snprint(s: PChar; l: csize_t; v: cunsigned): PChar external;

{ Return 1 when the specified format is little endian, return -1
 * when endianness does not apply to this format. \since 0.9.16 }
function pa_sample_format_is_le(f: TPASampleFormat): cint external;

{ Return 1 when the specified format is big endian, return -1 when
  endianness does not apply to this format. \since 0.9.16 }
function pa_sample_format_is_be(f: TPASampleFormat): cint external;



implementation

{ TPASampleSpec }

function TPASampleSpec.BytesPerSecond: csize_t;
begin
  Result := pa_bytes_per_second(@Self);
end;

function TPASampleSpec.SampleSize: csize_t;
begin
  Result := pa_sample_size(@Self);
end;

function TPASampleSpec.BytesToUSec(Length: QWord): QWord;
begin
  Result := pa_bytes_to_usec(Length, @Self);
end;

function TPASampleSpec.USecToBytes(t: QWord): csize_t;
begin
  Result := pa_usec_to_bytes(t, @Self);
end;

function TPASampleSpec.Valid: Boolean;
begin
  Result := pa_sample_spec_valid(@Self) <> 0;
end;

function TPASampleSpec.Equal(Spec: PPASampleSpec): Boolean;
begin
  Result := pa_sample_spec_equal(@self, Spec) <> 0;
end;

function TPASampleSpec.snprint(s: PChar; l: csize_t): PChar;
begin
  Result := pa_sample_spec_snprint(s,l, @Self);
end;

procedure TPASampleSpec.Init;
begin
  pa_sample_spec_init(@Self);
end;

end.

