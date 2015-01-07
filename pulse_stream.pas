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
unit pulse_stream;

{$mode objfpc}{$H+}
{$CALLING cdecl}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, pulse_sample, pulse_format, pulse_channelmap, pulse_volume,
  pulse_def, pulse_operation, pulse_context, pulse_proplist, ctypes;


type

{** An opaque stream for playback or recording *}
  PPAStream = ^TPAStream;

{** A generic callback for operation completion *}
  TPAStreamSuccessCB = procedure (s: PPAStream; success: cint; userdata: pointer);

{** A generic request callback *}
  TPAStreamRequestCB = procedure (p: PPAStream; nbites: csize_t; userdata: pointer);

{** A generic notification callback *}
  TPAStreamNotifyCB = procedure (p: PPAStream; userdata: pointer);

{** A callback for asynchronous meta/policy event messages. Well known
 * event names are PA_STREAM_EVENT_REQUEST_CORK and
 * PA_STREAM_EVENT_REQUEST_UNCORK. The set of defined events can be
 * extended at any time. Also, server modules may introduce additional
 * message types so make sure that your callback function ignores messages
 * it doesn't know. \since 0.9.15 *}
  TPAStreamEventCB = procedure (p: PPAStream; {const} name: pchar; pl: PPAProplist; userdata: pointer);

  { TPAStream }

  TPAStream = object sealed
    function  New(AContext: PPAContext;{const} AName: pchar; {const} ASpec: PPASampleSpec;
                 {const} AMap: PPAChannelMap): PPAStream; static;
    function  NewWithProplist(AContext: PPAContext;{const} AName: pchar; {const} ASpec: PPASampleSpec;
                 {const} AMap: PPAChannelMap; APropList: PPAProplist): PPAStream; static;
    function  NewExtended(AContext: PPAContext;{const} AName: pchar; {const} AFormats: PPPAFormatInfo;
                 AFormatCount: cuint; APropList: PPAProplist): PPAStream; static;
    procedure Unref;
    function  Ref: PPAStream;
    function  GetState: TPAStreamState;
    function  GetContext: PPAContext;
    function  GetIndex: LongWord;
    function  GetDeviceIndex: LongWord;
    function  GetDeviceName: PChar;
    function  IsSuspended: Boolean;
    function  IsCorked: Boolean;
    function  ConnectPlayback(dev: PChar; attr: PPABufferAttr; AFlags: LongWord{TPAStreamFlags};
                 AVolume: PPAChannelVolume; ASyncStream: PPAStream): cint;
    function  ConnectRecord(dev: PChar; Attr: PPABufferAttr;
                 AFlags: LongWord{TPAStreamFlags}): cint;
    function  Disconnect: cint;
    function  BeginWrite(Data: PPointer; ASize: csize_t): cint;
    function  CancelWrite: cint;
    function  Write(Data: Pointer; ASize: csize_t; AFreeCB: TPAFreeCB; AOffset: Int64; AMode: TPASeekMode): cint;
    function  Peek(Data: PPointer; ASize: csize_t): cint;
    function  Drop: cint;
    function  WritableSize: csize_t;
    function  ReadableSize: csize_t;
    function  Drain(ACB: TPAStreamSuccessCB; userdata: Pointer): PPAOperation;
    function  UpdateTimingInfo(ACB: TPAStreamSuccessCB; userdata: Pointer): PPAOperation;
    procedure SetStateCallback(ACB: TPAStreamNotifyCB; Userdata: Pointer);
    procedure SetWriteCallback(ACB: TPAStreamRequestCB; UserData: Pointer);
    procedure SetReadCallback(ACB: TPAStreamRequestCB; UserData: Pointer);
    procedure SetOverflowCallback(ACB: TPAStreamNotifyCB; Userdata: Pointer);
    function  GetUnderflowIndex: Int64;
    procedure SetUnderflowCallback(ACB: TPAStreamNotifyCB; Userdata: Pointer);
    procedure SetStartedCallback(ACB: TPAStreamNotifyCB; UserData: Pointer);
    procedure SetLatencyUpdateCallback(ACB: TPAStreamNotifyCB; UserData: Pointer);
    procedure SetStreamMovedCallback(ACB: TPAStreamNotifyCB; UserData: Pointer);
    procedure SetSuspendedCallback(ACB: TPAStreamNotifyCB; UserData: Pointer);
    procedure SetEventCallback(ACB: TPAStreamEventCB; UserData: Pointer);
    procedure SetBufferAttrCallback(ACB: TPAStreamNotifyCB; UserData: Pointer);
    function  Cork(ACork: Boolean; ACB: TPAStreamSuccessCB; Userdata: Pointer): PPAOperation;
    function  Flush(ACB: TPAStreamSuccessCB; Userdata: Pointer): PPAOperation;
    function  Prebuf(ACB: TPAStreamSuccessCB; Userdata: Pointer): PPAOperation;
    function  Trigger(ACB: TPAStreamSuccessCB; Userdata: Pointer): PPAOperation;
    function  SetName(AName: PChar; ACB: TPAStreamSuccessCB; Userdata: Pointer): PPAOperation;
    function  GetTime(uSecTime: PQWord): cint;
    function  GetLatency(uSecLatency: PQword; out IsNegative: Boolean): cint;
    function  GetTimingInfo: PPATimingInfo;
    function  GetSampleSpec: PPASampleSpec;
    function  GetChannelMap: PPAChannelMap;
    function  GetFormatInfo: PPAFormatInfo;
    function  GetBufferAttr: PPABufferAttr;
    function  SetBufferAttr(Attr: PPABufferAttr; ACB: TPAStreamSuccessCB; UserData: Pointer): PPAOperation;
    function  UpdateSampleRate(ARate: LongWord; ACB: TPAStreamSuccessCB; UserData: Pointer): PPAOperation;
    function  ProplistUpdate(AMode: TPAUpdateMode; AProplist: PPAProplist; ACB: TPAStreamSuccessCB; UserData: Pointer): PPAOperation;
    function  ProplistRemove(AKeys: PPChar; ACB: TPAStreamSuccessCB; UserData: Pointer): PPAOperation;
    function  SetMonitorStream(ASinkInputIndex: LongWord): cint;
    function  GetMonitorStream: LongWord;
  end;

{** Create a new, unconnected stream with the specified name and
 * sample type. It is recommended to use pa_stream_new_with_proplist()
 * instead and specify some initial properties. *}
function pa_stream_new(
        c: PPAContext                     {**< The context to create this stream in *};
        {const} name: pchar                  {**< A name for this stream *};
        {const} ss: PPASampleSpec          {**< The desired sample format *};
        {const} map: PPAChannelMap         {**< The desired channel map, or NULL for default *}
        ) : PPAStream external;

{** Create a new, unconnected stream with the specified name and
 * sample type, and specify the initial stream property
 * list. \since 0.9.11 *}
function pa_stream_new_with_proplist(
        c: PPAContext                     {**< The context to create this stream in *};
        {const} name: pchar                  {**< A name for this stream *};
        {const} ss: PPASampleSpec          {**< The desired sample format *};
        {const} map: PPAChannelMap         {**< The desired channel map, or NULL for default *};
        p: PPAProplist                    {**< The initial property list *}
        ): PPAStream external;

{** Create a new, unconnected stream with the specified name, the set of formats
 * this client can provide, and an initial list of properties. While
 * connecting, the server will select the most appropriate format which the
 * client must then provide. \since 1.0 *}
function pa_stream_new_extended(
        c: PPAContext           {**< The context to create this stream in *};
        {const} name: pchar     {**< A name for this stream *};
        formats: PPPAFormatInfo {**< The list of formats that can be provided *};
        n_formats: cunsigned    {**< The number of formats being passed in *};
        p: PPAProplist          {**< The initial property list *}
        ): PPAStream external;

{** Decrease the reference counter by one. *}
procedure pa_stream_unref(s: PPAStream) external;

{** Increase the reference counter by one. *}
function pa_stream_ref(s: PPAStream): PPAStream external;

{** Return the current state of the stream. *}
function pa_stream_get_state(p: PPAStream): TPAStreamState external;

{** Return the context this stream is attached to. *}
function pa_stream_get_context(p: PPAStream): PPAContext external;

{** Return the sink input resp.\ source output index this stream is
 * identified in the server with. This is useful with the
 * introspection functions such as pa_context_get_sink_input_info()
 * or pa_context_get_source_output_info(). *}
function pa_stream_get_index(s: PPAStream): LongWord external;

{** Return the index of the sink or source this stream is connected to
 * in the server. This is useful with the introspection
 * functions such as pa_context_get_sink_info_by_index() or
 * pa_context_get_source_info_by_index().
 *
 * Please note that streams may be moved between sinks/sources and thus
 * it is recommended to use pa_stream_set_moved_callback() to be notified
 * about this. This function will return with -PA_ERR_NOTSUPPORTED when the
 * server is older than 0.9.8. \since 0.9.8 *}
function pa_stream_get_device_index(s: PPAStream): LongWord external;

{** Return the name of the sink or source this stream is connected to
 * in the server. This is useful with the introspection
 * functions such as pa_context_get_sink_info_by_name()
 * or pa_context_get_source_info_by_name().
 *
 * Please note that streams may be moved between sinks/sources and thus
 * it is recommended to use pa_stream_set_moved_callback() to be notified
 * about this. This function will return with -PA_ERR_NOTSUPPORTED when the
 * server is older than 0.9.8. \since 0.9.8 *}
function pa_stream_get_device_name(s: PPAStream): PChar external;

{** Return 1 if the sink or source this stream is connected to has
 * been suspended. This will return 0 if not, and a negative value on
 * error. This function will return with -PA_ERR_NOTSUPPORTED when the
 * server is older than 0.9.8. \since 0.9.8 *}
function pa_stream_is_suspended(s: PPAStream): cint external;

{** Return 1 if the this stream has been corked. This will return 0 if
 * not, and a negative value on error. \since 0.9.11 *}
function pa_stream_is_corked(s: PPAStream): cint external;

{** Connect the stream to a sink. It is strongly recommended to pass
 * NULL in both \a dev and \a volume and to set neither
 * PA_STREAM_START_MUTED nor PA_STREAM_START_UNMUTED -- unless these
 * options are directly dependent on user input or configuration.
 *
 * If you follow this rule then the sound server will have the full
 * flexibility to choose the device, volume and mute status
 * automatically, based on server-side policies, heuristics and stored
 * information from previous uses. Also the server may choose to
 * reconfigure audio devices to make other sinks/sources or
 * capabilities available to be able to accept the stream.
 *
 * Before 0.9.20 it was not defined whether the \a volume parameter was
 * interpreted relative to the sink's current volume or treated as
 * an absolute device volume. Since 0.9.20 it is an absolute volume when
 * the sink is in flat volume mode, and relative otherwise, thus
 * making sure the volume passed here has always the same semantics as
 * the volume passed to pa_context_set_sink_input_volume(). It is possible
 * to figure out whether flat volume mode is in effect for a given sink
 * by calling pa_context_get_sink_info_by_name().
 *
 * Since 5.0, it's possible to specify a single-channel volume even if the
 * stream has multiple channels. In that case the same volume is applied to all
 * channels. *}
function pa_stream_connect_playback(
        s: PPAStream                   {**< The stream to connect to a sink *};
        {const} dev: pchar             {**< Name of the sink to connect to, or NULL for default *} ;
        {const} attr: PPABufferAttr    {**< Buffering attributes, or NULL for default *};
        flags :LongWord{TPAStreamFlags}{**< Additional flags, or 0 for default *};
        {const}volume: PPAChannelVolume{**< Initial volume, or NULL for default *};
        sync_stream: PPAStream         {**< Synchronize this stream with the specified one, or NULL for a standalone stream *}
        ): cint external;

{** Connect the stream to a source. *}
function pa_stream_connect_record(
        s: PPAStream                   {**< The stream to connect to a source *};
        {const} dev: pchar             {**< Name of the source to connect to, or NULL for default *};
        {const} attr: PPABufferAttr    {**< Buffer attributes, or NULL for default *};
        flags: LongWord{TPAStreamFlags}{**< Additional flags, or 0 for default *}
        ): cint external;

{** Disconnect a stream from a source/sink. *}
function pa_stream_disconnect(s: PPAStream): cint external;

{** Prepare writing data to the server (for playback streams). This
 * function may be used to optimize the number of memory copies when
 * doing playback ("zero-copy"). It is recommended to call this
 * function before each call to pa_stream_write().
 *
 * Pass in the address to a pointer and an address of the number of
 * bytes you want to write. On return the two values will contain a
 * pointer where you can place the data to write and the maximum number
 * of bytes you can write. \a *nbytes can be smaller or have the same
 * value as you passed in. You need to be able to handle both cases.
 * Accessing memory beyond the returned \a *nbytes value is invalid.
 * Accessing the memory returned after the following pa_stream_write()
 * or pa_stream_cancel_write() is invalid.
 *
 * On invocation only \a *nbytes needs to be initialized, on return both
 * *data and *nbytes will be valid. If you place (size_t) -1 in *nbytes
 * on invocation the memory size will be chosen automatically (which is
 * recommended to do). After placing your data in the memory area
 * returned, call pa_stream_write() with \a data set to an address
 * within this memory area and an \a nbytes value that is smaller or
 * equal to what was returned by this function to actually execute the
 * write.
 *
 * An invocation of pa_stream_write() should follow "quickly" on
 * pa_stream_begin_write(). It is not recommended letting an unbounded
 * amount of time pass after calling pa_stream_begin_write() and
 * before calling pa_stream_write(). If you want to cancel a
 * previously called pa_stream_begin_write() without calling
 * pa_stream_write() use pa_stream_cancel_write(). Calling
 * pa_stream_begin_write() twice without calling pa_stream_write() or
 * pa_stream_cancel_write() in between will return exactly the same
 * \a data pointer and \a nbytes values. \since 0.9.16 *}
function pa_stream_begin_write(
        p: PPAStream;
        data: PPointer;
        nbytes: csize_t): cint external;

{** Reverses the effect of pa_stream_begin_write() dropping all data
 * that has already been placed in the memory area returned by
 * pa_stream_begin_write(). Only valid to call if
 * pa_stream_begin_write() was called before and neither
 * pa_stream_cancel_write() nor pa_stream_write() have been called
 * yet. Accessing the memory previously returned by
 * pa_stream_begin_write() after this call is invalid. Any further
 * explicit freeing of the memory area is not necessary. \since
 * 0.9.16 *}
function pa_stream_cancel_write(p: PPAStream): cint external;

{** Write some data to the server (for playback streams).
 * If \a free_cb is non-NULL this routine is called when all data has
 * been written out. An internal reference to the specified data is
 * kept, the data is not copied. If NULL, the data is copied into an
 * internal buffer.
 *
 * The client may freely seek around in the output buffer. For
 * most applications it is typical to pass 0 and PA_SEEK_RELATIVE
 * as values for the arguments \a offset and \a seek. After the write
 * call succeeded the write index will be at the position after where
 * this chunk of data has been written to.
 *
 * As an optimization for avoiding needless memory copies you may call
 * pa_stream_begin_write() before this call and then place your audio
 * data directly in the memory area returned by that call. Then, pass
 * a pointer to that memory area to pa_stream_write(). After the
 * invocation of pa_stream_write() the memory area may no longer be
 * accessed. Any further explicit freeing of the memory area is not
 * necessary. It is OK to write the memory area returned by
 * pa_stream_begin_write() only partially with this call, skipping
 * bytes both at the end and at the beginning of the reserved memory
 * area.*}
function pa_stream_write(
        p: PPAStream          {**< The stream to use *};
        {const} data: Pointer {**< The data to write *};
        nbytes: csize_t       {**< The length of the data to write in bytes *};
        free_cb: TPAFreeCB    {**< A cleanup routine for the data or NULL to request an internal copy *};
        offset: Int64;        {**< Offset for seeking, must be 0 for upload streams *}
        seek: TPASeekMode     {**< Seek mode, must be PA_SEEK_RELATIVE for upload streams *}
        ): cint external;

{** Read the next fragment from the buffer (for recording streams).
 * If there is data at the current read index, \a data will point to
 * the actual data and \a nbytes will contain the size of the data in
 * bytes (which can be less or more than a complete fragment).
 *
 * If there is no data at the current read index, it means that either
 * the buffer is empty or it contains a hole (that is, the write index
 * is ahead of the read index but there's no data where the read index
 * points at). If the buffer is empty, \a data will be NULL and
 * \a nbytes will be 0. If there is a hole, \a data will be NULL and
 * \a nbytes will contain the length of the hole.
 *
 * Use pa_stream_drop() to actually remove the data from the buffer
 * and move the read index forward. pa_stream_drop() should not be
 * called if the buffer is empty, but it should be called if there is
 * a hole. *}
function pa_stream_peek(
        p: PPAStream                 {**< The stream to use *};
        {const} data: PPointer       {**< Pointer to pointer that will point to data *};
        nbytes: csize_t               {**< The length of the data read in bytes *}
        ): cint external;

{** Remove the current fragment on record streams. It is invalid to do this without first
 * calling pa_stream_peek(). *}
function pa_stream_drop(p: PPAStream): cint external;

{** Return the number of bytes that may be written using pa_stream_write(). *}
function pa_stream_writable_size(p: PPAStream): csize_t external;

{** Return the number of bytes that may be read using pa_stream_peek(). *}
function pa_stream_readable_size(p: PPAStream): csize_t external;

{** Drain a playback stream.  Use this for notification when the
 * playback buffer is empty after playing all the audio in the buffer.
 * Please note that only one drain operation per stream may be issued
 * at a time. *}
function pa_stream_drain(s: PPAStream; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Request a timing info structure update for a stream. Use
 * pa_stream_get_timing_info() to get access to the raw timing data,
 * or pa_stream_get_time() or pa_stream_get_latency() to get cleaned
 * up values. *}
function pa_stream_update_timing_info(p: PPAStream; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Set the callback function that is called whenever the state of the stream changes. *}
procedure pa_stream_set_state_callback(s: PPAStream; cb: TPAStreamNotifyCB; userdata: pointer) external;

{** Set the callback function that is called when new data may be
 * written to the stream. *}
procedure pa_stream_set_write_callback(p: PPAStream; cb: TPAStreamRequestCB; userdata: pointer) external;

{** Set the callback function that is called when new data is available from the stream. *}
procedure pa_stream_set_read_callback(p: PPAStream; cb: TPAStreamRequestCB; userdata: pointer) external;

{** Set the callback function that is called when a buffer overflow happens. (Only for playback streams) *}
procedure pa_stream_set_overflow_callback(p: PPAStream; cb: TPAStreamNotifyCB; userdata: pointer) external;

{** Return at what position the latest underflow occurred, or -1 if this information is not
 * known (e.g.\ if no underflow has occurred, or server is older than 1.0).
 * Can be used inside the underflow callback to get information about the current underflow.
 * (Only for playback streams) \since 1.0 *}
function pa_stream_get_underflow_index(p: PPAStream): Int64 external;

{** Set the callback function that is called when a buffer underflow happens. (Only for playback streams) *}
procedure pa_stream_set_underflow_callback(p: PPAStream; cb: TPAStreamNotifyCB; userdata: pointer) external;

{** Set the callback function that is called when a the server starts
 * playback after an underrun or on initial startup. This only informs
 * that audio is flowing again, it is no indication that audio started
 * to reach the speakers already. (Only for playback streams) \since
 * 0.9.11 *}
procedure pa_stream_set_started_callback(p: PPAStream; cb: TPAStreamNotifyCB; userdata: pointer) external;

{** Set the callback function that is called whenever a latency
 * information update happens. Useful on PA_STREAM_AUTO_TIMING_UPDATE
 * streams only. (Only for playback streams) *}
procedure pa_stream_set_latency_update_callback(p: PPAStream; cb: TPAStreamNotifyCB; userdata: pointer) external;

{** Set the callback function that is called whenever the stream is
 * moved to a different sink/source. Use pa_stream_get_device_name() or
 * pa_stream_get_device_index() to query the new sink/source. This
 * notification is only generated when the server is at least
 * 0.9.8. \since 0.9.8 *}
procedure pa_stream_set_moved_callback(p: PPAStream; cb: TPAStreamNotifyCB; userdata: pointer) external;

{** Set the callback function that is called whenever the sink/source
 * this stream is connected to is suspended or resumed. Use
 * pa_stream_is_suspended() to query the new suspend status. Please
 * note that the suspend status might also change when the stream is
 * moved between devices. Thus if you call this function you very
 * likely want to call pa_stream_set_moved_callback() too. This
 * notification is only generated when the server is at least
 * 0.9.8. \since 0.9.8 *}
procedure pa_stream_set_suspended_callback(p: PPAStream; cb: TPAStreamNotifyCB; userdata: pointer) external;

{** Set the callback function that is called whenever a meta/policy
 * control event is received. \since 0.9.15 *}
procedure pa_stream_set_event_callback(p: PPAStream; cb: TPAStreamEventCB; userdata: pointer) external;

{** Set the callback function that is called whenever the buffer
 * attributes on the server side change. Please note that the buffer
 * attributes can change when moving a stream to a different
 * sink/source too, hence if you use this callback you should use
 * pa_stream_set_moved_callback() as well. \since 0.9.15 *}
procedure pa_stream_set_buffer_attr_callback(p: PPAStream; cb: TPAStreamNotifyCB; userdata: pointer) external;

{** Pause (or resume) playback of this stream temporarily. Available
 * on both playback and recording streams. If \a b is 1 the stream is
 * paused. If \a b is 0 the stream is resumed. The pause/resume operation
 * is executed as quickly as possible. If a cork is very quickly
 * followed by an uncork or the other way round, this might not
 * actually have any effect on the stream that is output. You can use
 * pa_stream_is_corked() to find out whether the stream is currently
 * paused or not. Normally a stream will be created in uncorked
 * state. If you pass PA_STREAM_START_CORKED as a flag when connecting
 * the stream, it will be created in corked state. *}
function pa_stream_cork(s: PPAStream; b: cint; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Flush the playback or record buffer of this stream. This discards any audio data
 * in the buffer.  Most of the time you're better off using the parameter
 * \a seek of pa_stream_write() instead of this function. *}
function pa_stream_flush(s: PPAStream; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Reenable prebuffering if specified in the pa_buffer_attr
 * structure. Available for playback streams only. *}
function pa_stream_prebuf(s: PPAStream; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Request immediate start of playback on this stream. This disables
 * prebuffering temporarily if specified in the pa_buffer_attr structure.
 * Available for playback streams only. *}
function pa_stream_trigger(s: PPAStream; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Rename the stream. *}
function pa_stream_set_name(s: PPAStream; {const} name: pchar; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Return the current playback/recording time. This is based on the
 * data in the timing info structure returned by
 * pa_stream_get_timing_info().
 *
 * This function will usually only return new data if a timing info
 * update has been received. Only if timing interpolation has been
 * requested (PA_STREAM_INTERPOLATE_TIMING) the data from the last
 * timing update is used for an estimation of the current
 * playback/recording time based on the local time that passed since
 * the timing info structure has been acquired.
 *
 * The time value returned by this function is guaranteed to increase
 * monotonically (the returned value is always greater
 * or equal to the value returned by the last call). This behaviour
 * can be disabled by using PA_STREAM_NOT_MONOTONIC. This may be
 * desirable to better deal with bad estimations of transport
 * latencies, but may have strange effects if the application is not
 * able to deal with time going 'backwards'.
 *
 * The time interpolator activated by PA_STREAM_INTERPOLATE_TIMING
 * favours 'smooth' time graphs over accurate ones to improve the
 * smoothness of UI operations that are tied to the audio clock. If
 * accuracy is more important to you, you might need to estimate your
 * timing based on the data from pa_stream_get_timing_info() yourself
 * or not work with interpolated timing at all and instead always
 * query the server side for the most up to date timing with
 * pa_stream_update_timing_info().
 *
 * If no timing information has been
 * received yet this call will return -PA_ERR_NODATA. For more details
 * see pa_stream_get_timing_info(). *}
function pa_stream_get_time(s: PPAStream; r_usec: PQWord): cint external;

{** Determine the total stream latency. This function is based on
 * pa_stream_get_time().
 *
 * The latency is stored in \a *r_usec. In case the stream is a
 * monitoring stream the result can be negative, i.e. the captured
 * samples are not yet played. In this case \a *negative is set to 1.
 *
 * If no timing information has been received yet, this call will
 * return -PA_ERR_NODATA. On success, it will return 0.
 *
 * For more details see pa_stream_get_timing_info() and
 * pa_stream_get_time(). *}
function pa_stream_get_latency(s: PPAStream; r_usec: PQWord; negative: pcint): cint external;

{** Return the latest raw timing data structure. The returned pointer
 * refers to an internal read-only instance of the timing
 * structure. The user should make a copy of this structure if he
 * wants to modify it. An in-place update to this data structure may
 * be requested using pa_stream_update_timing_info().
 *
 * If no timing information has been received before (i.e. by
 * requesting pa_stream_update_timing_info() or by using
 * PA_STREAM_AUTO_TIMING_UPDATE), this function will fail with
 * -PA_ERR_NODATA.
 *
 * Please note that the write_index member field (and only this field)
 * is updated on each pa_stream_write() call, not just when a timing
 * update has been received. *}
function pa_stream_get_timing_info(s: PPAStream): PPATimingInfo external;

{** Return a pointer to the stream's sample specification. *}
function pa_stream_get_sample_spec(s: PPAStream): PPASampleSpec external;

{** Return a pointer to the stream's channel map. *}
function pa_stream_get_channel_map(s: PPAStream): PPAChannelMap external;

{** Return a pointer to the stream's format. \since 1.0 *}
function pa_stream_get_format_info(s: PPAStream): PPAFormatInfo external;

{** Return the per-stream server-side buffer metrics of the
 * stream. Only valid after the stream has been connected successfully
 * and if the server is at least PulseAudio 0.9. This will return the
 * actual configured buffering metrics, which may differ from what was
 * requested during pa_stream_connect_record() or
 * pa_stream_connect_playback(). This call will always return the
 * actual per-stream server-side buffer metrics, regardless whether
 * PA_STREAM_ADJUST_LATENCY is set or not. \since 0.9.0 *}
function pa_stream_get_buffer_attr(s: PPAStream): PPABufferAttr external;

{** Change the buffer metrics of the stream during playback. The
 * server might have chosen different buffer metrics then
 * requested. The selected metrics may be queried with
 * pa_stream_get_buffer_attr() as soon as the callback is called. Only
 * valid after the stream has been connected successfully and if the
 * server is at least PulseAudio 0.9.8. Please be aware of the
 * slightly different semantics of the call depending whether
 * PA_STREAM_ADJUST_LATENCY is set or not. \since 0.9.8 *}
function pa_stream_set_buffer_attr(s: PPAStream; {const} attr: PPABufferAttr; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Change the stream sampling rate during playback. You need to pass
 * PA_STREAM_VARIABLE_RATE in the flags parameter of
 * pa_stream_connect_playback() if you plan to use this function. Only valid
 * after the stream has been connected successfully and if the server
 * is at least PulseAudio 0.9.8. \since 0.9.8 *}
function pa_stream_update_sample_rate(s: PPAStream; rate: Longword; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Update the property list of the sink input/source output of this
 * stream, adding new entries. Please note that it is highly
 * recommended to set as many properties initially via
 * pa_stream_new_with_proplist() as possible instead a posteriori with
 * this function, since that information may be used to route
 * this stream to the right device. \since 0.9.11 *}
function pa_stream_proplist_update(s: PPAStream; mode: TPAUpdateMode; p: PPAProplist; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** Update the property list of the sink input/source output of this
 * stream, remove entries. \since 0.9.11 *}
function pa_stream_proplist_remove(s: PPAStream; {const} {const} keys: PPChar; cb: TPAStreamSuccessCB; userdata: pointer): PPAOperation external;

{** For record streams connected to a monitor source: monitor only a
 * very specific sink input of the sink. This function needs to be
 * called before pa_stream_connect_record() is called. \since
 * 0.9.11 *}
function pa_stream_set_monitor_stream(s: PPAStream; sink_input_idx: LongWord): cint external;

{** Return the sink input index previously set with
 * pa_stream_set_monitor_stream().
 * \since 0.9.11 *}
function pa_stream_get_monitor_stream(s: PPAStream): LongWord external;

implementation

{ TPAStream }

function TPAStream.New(AContext: PPAContext; AName: pchar;
  ASpec: PPASampleSpec; AMap: PPAChannelMap): PPAStream;
begin
  Result := pa_stream_new(AContext, AName, ASpec, AMap);
end;

function TPAStream.NewWithProplist(AContext: PPAContext; AName: pchar;
  ASpec: PPASampleSpec; AMap: PPAChannelMap; APropList: PPAProplist): PPAStream;
begin
  Result := pa_stream_new_with_proplist(AContext, AName, ASpec, AMap, APropList);
end;

function TPAStream.NewExtended(AContext: PPAContext; AName: pchar;
  AFormats: PPPAFormatInfo; AFormatCount: cuint; APropList: PPAProplist
  ): PPAStream;
begin
  Result := pa_stream_new_extended(AContext, AName, AFormats, AFormatCount, APropList);
end;

procedure TPAStream.Unref;
begin
  pa_stream_unref(@self);
end;

function TPAStream.Ref: PPAStream;
begin
  Result := pa_stream_ref(@self);
end;

function TPAStream.GetState: TPAStreamState;
begin
  Result := pa_stream_get_state(@self);
end;

function TPAStream.GetContext: PPAContext;
begin
  Result := pa_stream_get_context(@self);
end;

function TPAStream.GetIndex: LongWord;
begin
  Result := pa_stream_get_index(@self);
end;

function TPAStream.GetDeviceIndex: LongWord;
begin
  Result := pa_stream_get_device_index(@self);
end;

function TPAStream.GetDeviceName: PChar;
begin
  Result := pa_stream_get_device_name(@self);
end;

function TPAStream.IsSuspended: Boolean;
begin
  Result := pa_stream_is_suspended(@self) <> 0;
end;

function TPAStream.IsCorked: Boolean;
begin
  Result := pa_stream_is_corked(@self) <> 0;
end;

function TPAStream.ConnectPlayback(dev: PChar; attr: PPABufferAttr;
  AFlags: LongWord; AVolume: PPAChannelVolume; ASyncStream: PPAStream): cint;
begin
  Result := pa_stream_connect_playback(@self, dev, attr, aflags, avolume, ASyncStream);
end;

function TPAStream.ConnectRecord(dev: PChar;
  Attr: PPABufferAttr; AFlags: LongWord): cint;
begin
  Result := pa_stream_connect_record(@self, dev,attr,aflags);
end;

function TPAStream.Disconnect: cint;
begin
  Result := pa_stream_disconnect(@self);
end;

function TPAStream.BeginWrite(Data: PPointer; ASize: csize_t): cint;
begin
  Result := pa_stream_begin_write(@self, data, ASize);
end;

function TPAStream.CancelWrite: cint;
begin
  Result := pa_stream_cancel_write(@self);
end;

function TPAStream.Write(Data: Pointer; ASize: csize_t; AFreeCB: TPAFreeCB;
  AOffset: Int64; AMode: TPASeekMode): cint;
begin
  Result := pa_stream_write(@self, data, ASize, AFreeCB, AOffset, AMode);
end;

function TPAStream.Peek(Data: PPointer; ASize: csize_t): cint;
begin
  Result := pa_stream_peek(@self, data, ASize);
end;

function TPAStream.Drop: cint;
begin
  Result := pa_stream_drop(@self);
end;

function TPAStream.WritableSize: csize_t;
begin
  Result := pa_stream_writable_size(@self);
end;

function TPAStream.ReadableSize: csize_t;
begin
  Result := pa_stream_readable_size(@self);
end;

function TPAStream.Drain(ACB: TPAStreamSuccessCB; userdata: Pointer
  ): PPAOperation;
begin
  Result := pa_stream_drain(@self, Acb, userdata);
end;

function TPAStream.UpdateTimingInfo(ACB: TPAStreamSuccessCB; userdata: Pointer
  ): PPAOperation;
begin
  Result := pa_stream_update_timing_info(@self, ACB, userdata);
end;

procedure TPAStream.SetStateCallback(ACB: TPAStreamNotifyCB; Userdata: Pointer);
begin
  pa_stream_set_state_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetWriteCallback(ACB: TPAStreamRequestCB; UserData: Pointer
  );
begin
  pa_stream_set_write_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetReadCallback(ACB: TPAStreamRequestCB; UserData: Pointer);
begin
  pa_stream_set_read_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetOverflowCallback(ACB: TPAStreamNotifyCB;
  Userdata: Pointer);
begin
  pa_stream_set_overflow_callback(@self, ACB, userdata);
end;

function TPAStream.GetUnderflowIndex: Int64;
begin
  Result := pa_stream_get_underflow_index(@self);
end;

procedure TPAStream.SetUnderflowCallback(ACB: TPAStreamNotifyCB;
  Userdata: Pointer);
begin
  pa_stream_set_underflow_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetStartedCallback(ACB: TPAStreamNotifyCB; UserData: Pointer
  );
begin
  pa_stream_set_started_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetLatencyUpdateCallback(ACB: TPAStreamNotifyCB;
  UserData: Pointer);
begin
  pa_stream_set_latency_update_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetStreamMovedCallback(ACB: TPAStreamNotifyCB;
  UserData: Pointer);
begin
  pa_stream_set_moved_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetSuspendedCallback(ACB: TPAStreamNotifyCB;
  UserData: Pointer);
begin
  pa_stream_set_suspended_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetEventCallback(ACB: TPAStreamEventCB; UserData: Pointer);
begin
  pa_stream_set_event_callback(@self, ACB, userdata);
end;

procedure TPAStream.SetBufferAttrCallback(ACB: TPAStreamNotifyCB;
  UserData: Pointer);
begin
  pa_stream_set_buffer_attr_callback(@self, ACB, userdata);
end;

function TPAStream.Cork(ACork: Boolean; ACB: TPAStreamSuccessCB;
  Userdata: Pointer): PPAOperation;
begin
  Result := pa_stream_cork(@self, ord(ACork), ACB, userdata);
end;

function TPAStream.Flush(ACB: TPAStreamSuccessCB; Userdata: Pointer
  ): PPAOperation;
begin
  Result := pa_stream_flush(@self, ACB, userdata);
end;

function TPAStream.Prebuf(ACB: TPAStreamSuccessCB; Userdata: Pointer
  ): PPAOperation;
begin
  Result := pa_stream_prebuf(@self, ACB, userdata);
end;

function TPAStream.Trigger(ACB: TPAStreamSuccessCB; Userdata: Pointer
  ): PPAOperation;
begin
  Result := pa_stream_trigger(@self, ACB, userdata);
end;

function TPAStream.SetName(AName: PChar; ACB: TPAStreamSuccessCB;
  Userdata: Pointer): PPAOperation;
begin
  Result := pa_stream_set_name(@self, AName, ACB, userdata);
end;

function TPAStream.GetTime(uSecTime: PQWord): cint;
begin
  Result := pa_stream_get_time(@self, uSecTime);
end;

function TPAStream.GetLatency(uSecLatency: PQword; out IsNegative: Boolean): cint;
var
  neg: cint;
begin
  Result := pa_stream_get_latency(@self, uSecLatency, @neg);
  IsNegative:=  neg <> 0;
end;

function TPAStream.GetTimingInfo: PPATimingInfo;
begin
  Result := pa_stream_get_timing_info(@self);
end;

function TPAStream.GetSampleSpec: PPASampleSpec;
begin
  Result := pa_stream_get_sample_spec(@self)
end;

function TPAStream.GetChannelMap: PPAChannelMap;
begin
  Result := pa_stream_get_channel_map(@self);
end;

function TPAStream.GetFormatInfo: PPAFormatInfo;
begin
  Result := pa_stream_get_format_info(@self);
end;

function TPAStream.GetBufferAttr: PPABufferAttr;
begin
  Result := pa_stream_get_buffer_attr(@self);
end;

function TPAStream.SetBufferAttr(Attr: PPABufferAttr; ACB: TPAStreamSuccessCB;
  UserData: Pointer): PPAOperation;
begin
  Result := pa_stream_set_buffer_attr(@self, Attr, Acb, UserData);
end;

function TPAStream.UpdateSampleRate(ARate: LongWord; ACB: TPAStreamSuccessCB;
  UserData: Pointer): PPAOperation;
begin
  Result := pa_stream_update_sample_rate(@self, ARate, ACB, Userdata);
end;

function TPAStream.ProplistUpdate(AMode: TPAUpdateMode; AProplist: PPAProplist;
  ACB: TPAStreamSuccessCB; UserData: Pointer): PPAOperation;
begin
  Result := pa_stream_proplist_update(@self, AMode, AProplist, ACB, UserData);
end;

function TPAStream.ProplistRemove(AKeys: PPChar; ACB: TPAStreamSuccessCB;
  UserData: Pointer): PPAOperation;
begin
  Result := pa_stream_proplist_remove(@self, AKeys, ACB, UserData);
end;

function TPAStream.SetMonitorStream(ASinkInputIndex: LongWord): cint;
begin
  Result := pa_stream_set_monitor_stream(@self, ASinkInputIndex);
end;

function TPAStream.GetMonitorStream: LongWord;
begin
  Result := pa_stream_get_monitor_stream(@self);
end;

end.

