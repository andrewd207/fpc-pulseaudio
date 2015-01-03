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
unit pulse_def;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, pulse_sample, ctypes, unix;

type
  {** The state of a connection context *}
 TPAContextState = (
    csUNCONNECTED,    {**< The context hasn't been connected yet *}
    csCONNECTING,     {**< A connection is being established *}
    csAUTHORIZING,    {**< The client is authorizing itself to the daemon *}
    csSETTING_NAME,   {**< The client is passing its application name to the daemon *}
    csREADY,          {**< The connection is established, the context is ready to execute operations *}
    csFAILED,         {**< The connection failed or was disconnected *}
    csTERMINATED      {**< The connection was terminated cleanly *}
    );

  {** The state of a stream *}
   TPAStreamState = (
      ssUNCONNECTED,  {**< The stream is not yet connected to any sink or source *}
      ssCREATING,     {**< The stream is being created *}
      ssREADY,        {**< The stream is established, you may pass audio data to it now *}
      ssFAILED,       {**< An error occurred that made the stream invalid *}
      ssTERMINATED    {**< The stream has been terminated cleanly *}
      );

  {** The state of an operation *}
  TPAOperationState = (
    osRUNNING,
    {**< The operation is still running *}
    osDONE,
    {**< The operation has completed *}
    osCANCELLED
    {**< The operation has been cancelled. Operations may get cancelled by the
     * application, or as a result of the context getting disconneted while the
     * operation is pending. *}
    );

const
  {** An invalid index *}
  PA_INVALID_INDEX = -1;//((LongWord) -1)

type
  {** Some special flags for contexts. *}
 TPAContextFlags = set of (
    PA_CONTEXT_NOFLAGS = $0000,
    {**< Flag to pass when no specific options are needed (used to avoid casting)  \since 0.9.19 *}
    PA_CONTEXT_NOAUTOSPAWN = $0001,
    {**< Disabled autospawning of the PulseAudio daemon if required *}
    PA_CONTEXT_NOFAIL = $0002
    {**< Don't fail if the daemon is not available when pa_context_connect() is called, instead enter PA_CONTEXT_CONNECTING state and wait for the daemon to appear.  \since 0.9.15 *}
    );

  {** Direction bitfield - while we currently do not expose anything bidirectional,
  one should test against the bit instead of the value (e.g.\ if (d & PA_DIRECTION_OUTPUT)),
  because we might add bidirectional stuff in the future. \since 2.0
*}
 TPADirection = set of (
    PA_DIRECTION_OUTPUT = $0001,  {**< Output direction *}
    PA_DIRECTION_INPUT = $0002    {**< Input direction *}
    );

{** The type of device we are dealing with *}
 TPADeviceType = (
    dtSINK,     {**< Playback device *}
    dtSOURCE    {**< Recording device *}
    );

{** The direction of a pa_stream object *}
  TPAStreamDirection = (
    sdNODIRECTION,   {**< Invalid direction *}
    sdPLAYBACK,      {**< Playback stream *}
    sdRECORD,        {**< Record stream *}
    sdUPLOAD         {**< Sample upload stream *}
    );

{** Some special flags for stream connections. *}

  TPAStreamFlag =  (

    streamflagNOFLAGS = $0000,
    {**< Flag to pass when no specific options are needed (used to avoid casting)  \since 0.9.19 *}

    streamflagSTART_CORKED = $0001,
    {**< Create the stream corked, requiring an explicit
     * pa_stream_cork() call to uncork it. *}

    streamflagINTERPOLATE_TIMING = $0002,
    {**< Interpolate the latency for this stream. When enabled,
     * pa_stream_get_latency() and pa_stream_get_time() will try to
     * estimate the current record/playback time based on the local
     * time that passed since the last timing info update.  Using this
     * option has the advantage of not requiring a whole roundtrip
     * when the current playback/recording time is needed. Consider
     * using this option when requesting latency information
     * frequently. This is especially useful on long latency network
     * connections. It makes a lot of sense to combine this option
     * with streamflagAUTO_TIMING_UPDATE. *}

    streamflagNOT_MONOTONIC = $0004,
    {**< Don't force the time to increase monotonically. If this
     * option is enabled, pa_stream_get_time() will not necessarily
     * return always monotonically increasing time values on each
     * call. This may confuse applications which cannot deal with time
     * going 'backwards', but has the advantage that bad transport
     * latency estimations that caused the time to to jump ahead can
     * be corrected quickly, without the need to wait. (Please note
     * that this flag was named streamflagNOT_MONOTONOUS in releases
     * prior to 0.9.11. The old name is still defined too, for
     * compatibility reasons. *}

    streamflagAUTO_TIMING_UPDATE = $0008,
    {**< If set timing update requests are issued periodically
     * automatically. Combined with streamflagINTERPOLATE_TIMING you
     * will be able to query the current time and latency with
     * pa_stream_get_time() and pa_stream_get_latency() at all times
     * without a packet round trip.*}

    streamflagNO_REMAP_CHANNELS = $0010,
    {**< Don't remap channels by their name, instead map them simply
     * by their index. Implies streamflagNO_REMIX_CHANNELS. Only
     * supported when the server is at least PA 0.9.8. It is ignored
     * on older servers.\since 0.9.8 *}

    streamflagNO_REMIX_CHANNELS = $0020,
    {**< When remapping channels by name, don't upmix or downmix them
     * to related channels. Copy them into matching channels of the
     * device 1:1. Only supported when the server is at least PA
     * 0.9.8. It is ignored on older servers. \since 0.9.8 *}

    streamflagFIX_FORMAT = $0040,
    {**< Use the sample format of the sink/device this stream is being
     * connected to, and possibly ignore the format the sample spec
     * contains -- but you still have to pass a valid value in it as a
     * hint to PulseAudio what would suit your stream best. If this is
     * used you should query the used sample format after creating the
     * stream by using pa_stream_get_sample_spec(). Also, if you
     * specified manual buffer metrics it is recommended to update
     * them with pa_stream_set_buffer_attr() to compensate for the
     * changed frame sizes. Only supported when the server is at least
     * PA 0.9.8. It is ignored on older servers.
     *
     * When creating streams with pa_stream_new_extended(), this flag has no
     * effect. If you specify a format with PCM encoding, and you want the
     * server to choose the sample format, then you should leave the sample
     * format unspecified in the pa_format_info object. This also means that
     * you can't use pa_format_info_from_sample_spec(), because that function
     * always sets the sample format.
     *
     * \since 0.9.8 *}

    streamflagFIX_RATE = $0080,
    {**< Use the sample rate of the sink, and possibly ignore the rate
     * the sample spec contains. Usage similar to
     * streamflagFIX_FORMAT. Only supported when the server is at least
     * PA 0.9.8. It is ignored on older servers.
     *
     * When creating streams with pa_stream_new_extended(), this flag has no
     * effect. If you specify a format with PCM encoding, and you want the
     * server to choose the sample rate, then you should leave the rate
     * unspecified in the pa_format_info object. This also means that you can't
     * use pa_format_info_from_sample_spec(), because that function always sets
     * the sample rate.
     *
     * \since 0.9.8 *}

    streamflagFIX_CHANNELS = $0100,
    {**< Use the number of channels and the channel map of the sink,
     * and possibly ignore the number of channels and the map the
     * sample spec and the passed channel map contains. Usage similar
     * to streamflagFIX_FORMAT. Only supported when the server is at
     * least PA 0.9.8. It is ignored on older servers.
     *
     * When creating streams with pa_stream_new_extended(), this flag has no
     * effect. If you specify a format with PCM encoding, and you want the
     * server to choose the channel count and/or channel map, then you should
     * leave the channels and/or the channel map unspecified in the
     * pa_format_info object. This also means that you can't use
     * pa_format_info_from_sample_spec(), because that function always sets
     * the channel count (but if you only want to leave the channel map
     * unspecified, then pa_format_info_from_sample_spec() works, because it
     * accepts a NULL channel map).
     *
     * \since 0.9.8 *}

    streamflagDONT_MOVE = $0200,
    {**< Don't allow moving of this stream to another
     * sink/device. Useful if you use any of the streamflagFIX_ flags
     * and want to make sure that resampling never takes place --
     * which might happen if the stream is moved to another
     * sink/source with a different sample spec/channel map. Only
     * supported when the server is at least PA 0.9.8. It is ignored
     * on older servers. \since 0.9.8 *}

    streamflagVARIABLE_RATE = $0400,
    {**< Allow dynamic changing of the sampling rate during playback
     * with pa_stream_update_sample_rate(). Only supported when the
     * server is at least PA 0.9.8. It is ignored on older
     * servers. \since 0.9.8 *}

    streamflagPEAK_DETECT = $0800,
    {**< Find peaks instead of resampling. \since 0.9.11 *}

    streamflagSTART_MUTED = $1000,
    {**< Create in muted state. If neither streamflagSTART_UNMUTED nor
     * streamflagSTART_MUTED it is left to the server to decide
     * whether to create the stream in muted or in unmuted
     * state. \since 0.9.11 *}

    streamflagADJUST_LATENCY = $2000,
    {**< Try to adjust the latency of the sink/source based on the
     * requested buffer metrics and adjust buffer metrics
     * accordingly. Also see pa_buffer_attr. This option may not be
     * specified at the same time as streamflagEARLY_REQUESTS. \since
     * 0.9.11 *}

    streamflagEARLY_REQUESTS = $4000,
    {**< Enable compatibility mode for legacy clients that rely on a
     * 'classic' hardware device fragment-style playback model. If
     * this option is set, the minreq value of the buffer metrics gets
     * a new meaning: instead of just specifying that no requests
     * asking for less new data than this value will be made to the
     * client it will also guarantee that requests are generated as
     * early as this limit is reached. This flag should only be set in
     * very few situations where compatibility with a fragment-based
     * playback model needs to be kept and the client applications
     * cannot deal with data requests that are delayed to the latest
     * moment possible. (Usually these are programs that use usleep()
     * or a similar call in their playback loops instead of sleeping
     * on the device itself.) Also see pa_buffer_attr. This option may
     * not be specified at the same time as
     * streamflagADJUST_LATENCY. \since 0.9.12 *}

    streamflagDONT_INHIBIT_AUTO_SUSPEND = $8000,
    {**< If set this stream won't be taken into account when it is
     * checked whether the device this stream is connected to should
     * auto-suspend. \since 0.9.15 *}

    streamflagSTART_UNMUTED = $10000,
    {**< Create in unmuted state. If neither streamflagSTART_UNMUTED
     * nor streamflagSTART_MUTED it is left to the server to decide
     * whether to create the stream in muted or in unmuted
     * state. \since 0.9.15 *}

    streamflagFAIL_ON_SUSPEND = $20000,
    {**< If the sink/source this stream is connected to is suspended
     * during the creation of this stream, cause it to fail. If the
     * sink/source is being suspended during creation of this stream,
     * make sure this stream is terminated. \since 0.9.15 *}

    streamflagRELATIVE_VOLUME = $40000,
    {**< If a volume is passed when this stream is created, consider
     * it relative to the sink's current volume, never as absolute
     * device volume. If this is not specified the volume will be
     * consider absolute when the sink is in flat volume mode,
     * relative otherwise. \since 0.9.20 *}

    streamflagPASSTHROUGH = $80000
    {**< Used to tag content that will be rendered by passthrough sinks.
     * The data will be left as is and not reformatted, resampled.
     * \since 1.0 *}

     );
  //TPAStreamFlags = set of TPAStreamFlag;

const
  {* English is an evil language *}
  streamflagNOT_MONOTONOUS = streamflagNOT_MONOTONIC;

type
  {** Playback and record buffer metrics *}
  PPABufferAttr = ^TPABufferAttr;
   TPABufferAttr = record
      maxlength: LongWord;
      {**< Maximum length of the buffer in bytes. Setting this to (LongWord) -1
       * will initialize this to the maximum value supported by server,
       * which is recommended.
       *
       * In strict low-latency playback scenarios you might want to set this to
       * a lower value, likely together with the sfADJUST_LATENCY flag.
       * If you do so, you ensure that the latency doesn't grow beyond what is
       * acceptable for the use case, at the cost of getting more underruns if
       * the latency is lower than what the server can reliably handle. *}

      tlength: LongWord;
      {**< Playback only: target length of the buffer. The server tries
       * to assure that at least tlength bytes are always available in
       * the per-stream server-side playback buffer. It is recommended
       * to set this to (LongWord) -1, which will initialize this to a
       * value that is deemed sensible by the server. However, this
       * value will default to something like 2s, i.e. for applications
       * that have specific latency requirements this value should be
       * set to the maximum latency that the application can deal
       * with. When PA_STREAM_ADJUST_LATENCY is not set this value will
       * influence only the per-stream playback buffer size. When
       * PA_STREAM_ADJUST_LATENCY is set the overall latency of the sink
       * plus the playback buffer size is configured to this value. Set
       * PA_STREAM_ADJUST_LATENCY if you are interested in adjusting the
       * overall latency. Don't set it if you are interested in
       * configuring the server-side per-stream playback buffer
       * size. *}

      prebuf: LongWord;
      {**< Playback only: pre-buffering. The server does not start with
       * playback before at least prebuf bytes are available in the
       * buffer. It is recommended to set this to (LongWord) -1, which
       * will initialize this to the same value as tlength, whatever
       * that may be. Initialize to 0 to enable manual start/stop
       * control of the stream. This means that playback will not stop
       * on underrun and playback will not start automatically. Instead
       * pa_stream_cork() needs to be called explicitly. If you set
       * this value to 0 you should also set PA_STREAM_START_CORKED. *}

      minreq: LongWord;
      {**< Playback only: minimum request. The server does not request
       * less than minreq bytes from the client, instead waits until the
       * buffer is free enough to request more bytes at once. It is
       * recommended to set this to (LongWord) -1, which will initialize
       * this to a value that is deemed sensible by the server. This
       * should be set to a value that gives PulseAudio enough time to
       * move the data from the per-stream playback buffer into the
       * hardware playback buffer. *}

      fragsize: LongWord;
      {**< Recording only: fragment size. The server sends data in
       * blocks of fragsize bytes size. Large values diminish
       * interactivity with other operations on the connection context
       * but decrease control overhead. It is recommended to set this to
       * (LongWord) -1, which will initialize this to a value that is
       * deemed sensible by the server. However, this value will default
       * to something like 2s, i.e. for applications that have specific
       * latency requirements this value should be set to the maximum
       * latency that the application can deal with. If
       * PA_STREAM_ADJUST_LATENCY is set the overall source latency will
       * be adjusted according to this value. If it is not set the
       * source latency is left unmodified. *}

  end;
    {** Error values as used by pa_context_errno(). Use pa_strerror() to convert these values to human readable strings *}
     TPAErrorCord = (
        ecOK = 0,                     {**< No error *}
        ecACCESS,                 {**< Access failure *}
        ecCOMMAND,                {**< Unknown command *}
        ecINVALID,                {**< Invalid argument *}
        ecEXIST,                  {**< Entity exists *}
        ecNOENTITY,               {**< No such entity *}
        ecCONNECTIONREFUSED,      {**< Connection refused *}
        ecPROTOCOL,               {**< Protocol error *}
        ecTIMEOUT,                {**< Timeout *}
        ecAUTHKEY,                {**< No authorization key *}
        ecINTERNAL,               {**< Internal error *}
        ecCONNECTIONTERMINATED,   {**< Connection terminated *}
        ecKILLED,                 {**< Entity killed *}
        ecINVALIDSERVER,          {**< Invalid server *}
        ecMODINITFAILED,          {**< Module initialization failed *}
        ecBADSTATE,               {**< Bad state *}
        ecNODATA,                 {**< No data *}
        ecVERSION,                {**< Incompatible protocol version *}
        ecTOOLARGE,               {**< Data too large *}
        ecNOTSUPPORTED,           {**< Operation not supported \since 0.9.5 *}
        ecUNKNOWN,                {**< The error code was unknown to the client *}
        ecNOEXTENSION,            {**< Extension does not exist. \since 0.9.12 *}
        ecOBSOLETE,               {**< Obsolete functionality. \since 0.9.15 *}
        ecNOTIMPLEMENTED,         {**< Missing implementation. \since 0.9.15 *}
        ecFORKED,                 {**< The caller forked without calling execve() and tried to reuse the context. \since 0.9.15 *}
        ecIO,                     {**< An IO error happened. \since 0.9.16 *}
        ecBUSY,                   {**< Device or resource busy. \since 0.9.17 *}
        ecMAX                     {**< Not really an error but the first invalid error code *}
    );

    {** Subscription event mask, as used by pa_context_subscribe() *}
    TPASubscriptionMask = (
        smNULL = $0000,
        {**< No events *}

        smSINK = $0001,
        {**< Sink events *}

        smSOURCE = $0002,
        {**< Source events *}

        smSINK_INPUT = $0004,
        {**< Sink input events *}

        smSOURCE_OUTPUT = $0008,
        {**< Source output events *}

        smMODULE = $0010,
        {**< Module events *}

        smCLIENT = $0020,
        {**< Client events *}

        smSAMPLE_CACHE = $0040,
        {**< Sample cache events *}

        smSERVER = $0080,
        {**< Other global server changes. *}

    {** \cond fulldocs *}
        smAUTOLOAD = $0100,
        {**< \deprecated Autoload table events. *}
    {** \endcond *}

        smCARD = $0200,
        {**< Card events. \since 0.9.15 *}

        smALL = $02ff
        {**< Catch all events *}
    );

    {** Subscription event types, as used by pa_context_subscribe() *}
     TPASubcriptionEventType = (
        setSINK = $0000,
        {**< Event type: Sink *}

        setSOURCE = $0001,
        {**< Event type: Source *}

        setSINK_INPUT = $0002,
        {**< Event type: Sink input *}

        setSOURCE_OUTPUT = $0003,
        {**< Event type: Source output *}

        setMODULE = $0004,
        {**< Event type: Module *}

        setCLIENT = $0005,
        {**< Event type: Client *}

        setSAMPLE_CACHE = $0006,
        {**< Event type: Sample cache item *}

        setSERVER = $0007,
        {**< Event type: Global server change, only occurring with setCHANGE. *}

    {** \cond fulldocs *}
        setAUTOLOAD = $0008,
        {**< \deprecated Event type: Autoload table changes. *}
    {** \endcond *}

        setCARD = $0009,
        {**< Event type: Card \since 0.9.15 *}

        setFACILITY_MASK = $000F,
        {**< A mask to extract the event type from an event value *}

        setNEW = $0000,
        {**< A new object was created *}

        setCHANGE = $0010,
        {**< A property of the object was modified *}

        setREMOVE = $0020,
        {**< An object was removed *}

        setTYPE_MASK = $0030
        {**< A mask to extract the event operation from an event value *}

    );

    {** A structure for all kinds of timing information of a stream. See
     * pa_stream_update_timing_info() and pa_stream_get_timing_info(). The
     * total output latency a sample that is written with
     * pa_stream_write() takes to be played may be estimated by
     * sink_usec+buffer_usec+transport_usec. (where buffer_usec is defined
     * as pa_bytes_to_usec(write_index-read_index)) The output buffer
     * which buffer_usec relates to may be manipulated freely (with
     * pa_stream_write()'s seek argument, pa_stream_flush() and friends),
     * the buffers sink_usec and source_usec relate to are first-in
     * first-out (FIFO) buffers which cannot be flushed or manipulated in
     * any way. The total input latency a sample that is recorded takes to
     * be delivered to the application is:
     * source_usec+buffer_usec+transport_usec-sink_usec. (Take care of
     * sign issues!) When connected to a monitor source sink_usec contains
     * the latency of the owning sink. The two latency estimations
     * described here are implemented in pa_stream_get_latency(). Please
     * note that this structure can be extended as part of evolutionary
     * API updates at any time in any new release.*}
     TPATimingInfo = record
        timestamp: timeval;
        {**< The time when this timing info structure was current *}

        synchronized_clocks: cint;
        {**< Non-zero if the local and the remote machine have
         * synchronized clocks. If synchronized clocks are detected
         * transport_usec becomes much more reliable. However, the code
         * that detects synchronized clocks is very limited and unreliable
         * itself. *}

        sink_usec: QWord;
        {**< Time in usecs a sample takes to be played on the sink. For
         * playback streams and record streams connected to a monitor
         * source. *}

        source_usec: QWord;
        {**< Time in usecs a sample takes from being recorded to being
         * delivered to the application. Only for record streams. *}

        transport_usec: QWord;
        {**< Estimated time in usecs a sample takes to be transferred
         * to/from the daemon. For both playback and record streams. *}

        playing: cint;
        {**< Non-zero when the stream is currently not underrun and data
         * is being passed on to the device. Only for playback
         * streams. This field does not say whether the data is actually
         * already being played. To determine this check whether
         * since_underrun (converted to usec) is larger than sink_usec.*}

        write_index_corrupt: cint;
        {**< Non-zero if write_index is not up-to-date because a local
         * write command that corrupted it has been issued in the time
         * since this latency info was current . Only write commands with
         * SEEK_RELATIVE_ON_READ and SEEK_RELATIVE_END can corrupt
         * write_index. *}

        write_index: Int64;
        {**< Current write index into the playback buffer in bytes. Think
         * twice before using this for seeking purposes: it might be out
         * of date a the time you want to use it. Consider using
         * PA_SEEK_RELATIVE instead. *}

        read_index_corrupt: cint;
        {**< Non-zero if read_index is not up-to-date because a local
         * pause or flush request that corrupted it has been issued in the
         * time since this latency info was current. *}

        read_index: Int64;
        {**< Current read index into the playback buffer in bytes. Think
         * twice before using this for seeking purposes: it might be out
         * of date a the time you want to use it. Consider using
         * PA_SEEK_RELATIVE_ON_READ instead. *}

        configured_sink_usec: QWord;
        {**< The configured latency for the sink. \since 0.9.11 *}

        configured_source_usec: QWord;
        {**< The configured latency for the source. \since 0.9.11 *}

        since_underrun: Int64;
        {**< Bytes that were handed to the sink since the last underrun
         * happened, or since playback started again after the last
         * underrun. playing will tell you which case it is. \since
         * 0.9.11 *}

    end;

    {** A structure for the spawn api. This may be used to integrate auto
     * spawned daemons into your application. For more information see
     * pa_context_connect(). When spawning a new child process the
     * waitpid() is used on the child's PID. The spawn routine will not
     * block or ignore SIGCHLD signals, since this cannot be done in a
     * thread compatible way. You might have to do this in
     * prefork/postfork. *}
     TPASpawnApi = record
        prefork: procedure;
        //void (*prefork)(void);
        {**< Is called just before the fork in the parent process. May be
         * NULL. *}
        postfork: procedure;
        //void (*postfork)(void);
        {**< Is called immediately after the fork in the parent
         * process. May be NULL.*}
        atfork: procedure;
        //void (*atfork)(void);
        {**< Is called immediately after the fork in the child
         * process. May be NULL. It is not safe to close all file
         * descriptors in this function unconditionally, since a UNIX
         * socket (created using socketpair()) is passed to the new
         * process. *}
    end;

    {** Seek type for pa_stream_write(). *}
     TPASeekMode= (
        smRELATIVE = 0,
        {**< Seek relatively to the write index *}

        smABSOLUTE = 1,
        {**< Seek relatively to the start of the buffer queue *}

        smRELATIVE_ON_READ = 2,
        {**< Seek relatively to the read index.  *}

        smRELATIVE_END = 3
        {**< Seek relatively to the current end of the buffer queue. *}
     );

    {** Special sink flags. *}
     TPASinkFlags = (
        sinkflgNOFLAGS = $0000,
        {**< Flag to pass when no specific options are needed (used to avoid casting)  \since 0.9.19 *}

        sinkflgHW_VOLUME_CTRL = $0001,
        {**< Supports hardware volume control. This is a dynamic flag and may
         * change at runtime after the sink has initialized *}

        sinkflgLATENCY = $0002,
        {**< Supports latency querying *}

        sinkflgHARDWARE = $0004,
        {**< Is a hardware sink of some kind, in contrast to
         * 'virtual'/software sinks \since 0.9.3 *}

        sinkflgNETWORK = $0008,
        {**< Is a networked sink of some kind. \since 0.9.7 *}

        sinkflgHW_MUTE_CTRL = $0010,
        {**< Supports hardware mute control. This is a dynamic flag and may
         * change at runtime after the sink has initialized \since 0.9.11 *}

        sinkflgDECIBEL_VOLUME = $0020,
        {**< Volume can be translated to dB with pa_sw_volume_to_dB(). This is a
         * dynamic flag and may change at runtime after the sink has initialized
         * \since 0.9.11 *}

        sinkflgFLAT_VOLUME = $0040,
        {**< This sink is in flat volume mode, i.e.\ always the maximum of
         * the volume of all connected inputs. \since 0.9.15 *}

        sinkflgDYNAMIC_LATENCY = $0080,
        {**< The latency can be adjusted dynamically depending on the
         * needs of the connected streams. \since 0.9.15 *}

        sinkflgSET_FORMATS = $0100
        {**< The sink allows setting what formats are supported by the connected
         * hardware. The actual functionality to do this might be provided by an
         * extension. \since 1.0 *}
    );

    {** Sink state. \since 0.9.15 *}
     TPASinkState = ( {* enum serialized in u8 *}
        ssINVALID_STATE = -1,
        {**< This state is used when the server does not support sink state introspection \since 0.9.15 *}

        ssRUNNING = 0,
        {**< Running, sink is playing and used by at least one non-corked sink-input \since 0.9.15 *}

        ssIDLE = 1,
        {**< When idle, the sink is playing but there is no non-corked sink-input attached to it \since 0.9.15 *}

        ssSUSPENDED = 2
        {**< When suspended, actual sink access can be closed, for instance \since 0.9.15 *}
     );
    {** Special source flags.  *}
     TPASourceFlags = (
        sourceflgNOFLAGS = $0000,
        {**< Flag to pass when no specific options are needed (used to avoid casting)  \since 0.9.19 *}

        sourceflgHW_VOLUME_CTRL = $0001,
        {**< Supports hardware volume control. This is a dynamic flag and may
         * change at runtime after the source has initialized *}

        sourceflgLATENCY = $0002,
        {**< Supports latency querying *}

        sourceflgHARDWARE = $0004,
        {**< Is a hardware source of some kind, in contrast to
         * 'virtual'/software source \since 0.9.3 *}

        sourceflgNETWORK = $0008,
        {**< Is a networked source of some kind. \since 0.9.7 *}

        sourceflgHW_MUTE_CTRL = $0010,
        {**< Supports hardware mute control. This is a dynamic flag and may
         * change at runtime after the source has initialized \since 0.9.11 *}

        sourceflgDECIBEL_VOLUME = $0020,
        {**< Volume can be translated to dB with pa_sw_volume_to_dB(). This is a
         * dynamic flag and may change at runtime after the source has initialized
         * \since 0.9.11 *}

        sourceflgDYNAMIC_LATENCY = $0040,
        {**< The latency can be adjusted dynamically depending on the
         * needs of the connected streams. \since 0.9.15 *}

        sourceflgFLAT_VOLUME = $0080
        {**< This source is in flat volume mode, i.e.\ always the maximum of
         * the volume of all connected outputs. \since 1.0 *}
    );

    {** Source state. \since 0.9.15 *}
 TPASourceState = (
    sourcestateINVALID_STATE = -1,
    {**< This state is used when the server does not support source state introspection \since 0.9.15 *}

    sourcestateRUNNING = 0,
    {**< Running, source is recording and used by at least one non-corked source-output \since 0.9.15 *}

    sourcestateIDLE = 1,
    {**< When idle, the source is still recording but there is no non-corked source-output \since 0.9.15 *}

    sourcestateSUSPENDED = 2
    {**< When suspended, actual source access can be closed, for instance \since 0.9.15 *}

 );

const
  {** A stream policy/meta event requesting that an application should
 * cork a specific stream. See pa_stream_event_cb_t for more
 * information. \since 0.9.15 *}
  PA_STREAM_EVENT_REQUEST_CORK = 'request-cork';

{** A stream policy/meta event requesting that an application should
 * cork a specific stream. See pa_stream_event_cb_t for more
 * information, \since 0.9.15 *}
  PA_STREAM_EVENT_REQUEST_UNCORK = 'request-uncork';

{** A stream event notifying that the stream is going to be
 * disconnected because the underlying sink changed and no longer
 * supports the format that was originally negotiated. Clients need
 * to connect a new stream to renegotiate a format and continue
 * playback. \since 1.0 *}
  PA_STREAM_EVENT_FORMAT_LOST = 'format-lost';
implementation

end.

