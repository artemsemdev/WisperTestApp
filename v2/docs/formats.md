# VoxFlow v2 transcript formats

All transcript output formats guarantee determinism: given the same audio and model, you get the same file bytes every time. Line endings are Unix (`\n`), with a single trailing newline. JSON objects have keys sorted alphabetically. Dates use ISO 8601 format in UTC.

## Text (TXT)

Plain text transcript, one segment per line.

**With timestamps:**

```
[00:00:00.000 → 00:00:04.120] Welcome back. Today we're picking up where we left off.
[00:00:04.120 → 00:00:09.860] Last week we covered why fixed-length context vectors become a bottleneck.
```

**Without timestamps:**

```
Welcome back. Today we're picking up where we left off.
Last week we covered why fixed-length context vectors become a bottleneck.
```

## SubRip (SRT)

Standard subtitle format with sequence numbers and timecodes.

```
1
00:00:00,000 --> 00:00:04,120
Welcome back. Today we're picking up where we left off.

2
00:00:04,120 --> 00:00:09,860
Last week we covered why fixed-length context vectors become a bottleneck.
```

## WebVTT (VTT)

Web video text track format, used by video players and browsers.

```
WEBVTT

00:00:00.000 --> 00:00:04.120
Welcome back. Today we're picking up where we left off.

00:00:04.120 --> 00:00:09.860
Last week we covered why fixed-length context vectors become a bottleneck.
```

## JSON

Structured format including metadata and segment details.

```json
{
  "createdAt": "2025-09-08T00:00:00Z",
  "duration": 9.86,
  "generator": "VoxFlow 2.0.0-dev",
  "language": "en",
  "model": "whisper-large-v3-turbo",
  "processingTime": 0.62,
  "segments": [
    {
      "confidence": 0.91,
      "end": 4.12,
      "start": 0,
      "text": "Welcome back. Today we're picking up where we left off."
    },
    {
      "end": 9.86,
      "start": 4.12,
      "text": "Last week we covered why fixed-length context vectors become a bottleneck."
    }
  ],
  "source": "lecture-04.wav",
  "words": 21
}
```

### JSON fields

| Field | Type | Description |
|-------|------|-------------|
| `source` | string | Filename of the source audio file |
| `language` | string | ISO 639-1 language code |
| `model` | string | Model ID used for transcription |
| `duration` | number | Audio duration in seconds |
| `processingTime` | number | Processing time in seconds |
| `createdAt` | string | Timestamp in ISO 8601 format (UTC) |
| `words` | integer | Total word count in the transcript |
| `generator` | string | VoxFlow version identifier |
| `segments` | array | Array of transcript segments |
| `segments[].start` | number | Segment start time in seconds |
| `segments[].end` | number | Segment end time in seconds |
| `segments[].text` | string | Segment text content |
| `segments[].confidence` | number | (optional) Confidence score (0–1), present only when available |

`generator` carries the app version (`VoxFlow <version>`), so it changes with releases; every other byte of the example is stable.

## Markdown (MD)

Human-readable format with document title and metadata header.

**With timestamps:**

```markdown
# lecture-04

_0:10 · en · whisper-large-v3-turbo_

**[0:00]** Welcome back. Today we're picking up where we left off.

**[0:04]** Last week we covered why fixed-length context vectors become a bottleneck.
```

**Without timestamps:**

```markdown
# lecture-04

_0:10 · en · whisper-large-v3-turbo_

Welcome back. Today we're picking up where we left off.

Last week we covered why fixed-length context vectors become a bottleneck.
```

## Timestamps

Timestamps use different formats depending on the output format:

| Format | Pattern | Example | Notes |
|--------|---------|---------|-------|
| SRT | `HH:MM:SS,mmm` | `00:00:04,120` | SubRip uses commas for milliseconds |
| VTT / TXT brackets | `HH:MM:SS.mmm` | `00:00:04.120` | Uses periods for milliseconds |
| Markdown | `M:SS` or `H:MM:SS` | `0:04` or `1:23:45` | Rounded to nearest second |

## Export

Transcripts are exported to `~/Transcripts` by default. The exporter creates the directory if needed.

**Naming:** Files are named `<basename>.<extension>`. When a file already exists, the exporter appends a counter: `<basename>-2.<extension>`, `<basename>-3.<extension>`, and so on. Files are never overwritten.

**Batch export:** All formats can be re-exported from the same transcript document without re-processing the audio. Use the same source transcript document to export in different formats or with different timestamp settings.
