import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/src/thumbnail_viewer.dart';
import 'package:video_trimmer/src/trim_editor_painter.dart';

// VideoPlayerController _videoPlayerController;

class TrimEditor extends StatefulWidget {
  /// For defining the total trimmer area width
  final double viewerWidth;

  //predefined start time

  final double startTime;

  //predefined end time

  final double endTime;

  //for the thumbnailgeneration
  final File videoFile;

  // the editing video controller
  final VideoPlayerController videoPlayerController;

  /// For defining the total trimmer area height
  final double viewerHeight;

  /// For defining the image fit type of each thumbnail image.
  ///
  /// By default it is set to `BoxFit.fitHeight`.
  final BoxFit fit;

  /// For defining the maximum length of the output video.
  final Duration maxVideoLength;

  /// For specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  ///
  /// By default it is set to `5.0`.
  final double circleSize;

  /// For specifying a size to the holder at
  /// the two ends of the video trimmer area, while it is being
  /// `dragged`.
  ///
  /// By default it is set to `8.0`.
  final double circleSizeOnDrag;

  /// For specifying a color to the circle.
  ///
  /// By default it is set to `Colors.white`.
  final Color circlePaintColor;

  /// For specifying a color to the border of
  /// the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color borderPaintColor;

  /// For specifying a color to the video
  /// scrubber inside the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color scrubberPaintColor;

  /// For specifying the quality of each
  /// generated image thumbnail, to be displayed in the trimmer
  /// area.
  final int thumbnailQuality;

  /// For showing the start and the end point of the
  /// video on top of the trimmer area.
  ///
  /// By default it is set to `true`.
  final bool showDuration;

  /// For providing a `TextStyle` to the
  /// duration text.
  ///
  /// By default it is set to `TextStyle(color: Colors.white)`
  final TextStyle durationTextStyle;

  /// Callback to the video start position
  ///
  /// Returns the selected video start position in `milliseconds`.
  final Function(double startValue) onChangeStart;

  /// Callback to the video end position.
  ///
  /// Returns the selected video end position in `milliseconds`.
  final Function(double endValue) onChangeEnd;

  /// Callback to the video playback
  /// state to know whether it is currently playing or paused.
  ///
  /// Returns a `boolean` value. If `true`, video is currently
  /// playing, otherwise paused.
  final Function(bool isPlaying) onChangePlaybackState;

  final Function(double startPosition, double endPosition) onHorizontalDragEnd;

  /// Widget for displaying the video trimmer.
  ///
  /// This has frame wise preview of the video with a
  /// slider for selecting the part of the video to be
  /// trimmed.
  ///
  /// The required parameters are [viewerWidth] & [viewerHeight]
  ///
  /// * [viewerWidth] to define the total trimmer area width.
  ///
  ///
  /// * [viewerHeight] to define the total trimmer area height.
  ///
  ///
  /// The optional parameters are:
  ///
  /// * [fit] for specifying the image fit type of each thumbnail image.
  /// By default it is set to `BoxFit.fitHeight`.
  ///
  ///
  /// * [maxVideoLength] for specifying the maximum length of the
  /// output video.
  ///
  ///
  /// * [circleSize] for specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  /// By default it is set to `5.0`.
  ///
  ///
  /// * [circleSizeOnDrag] for specifying a size to the holder at
  /// the two ends of the video trimmer area, while it is being
  /// `dragged`. By default it is set to `8.0`.
  ///
  ///
  /// * [circlePaintColor] for specifying a color to the circle.
  /// By default it is set to `Colors.white`.
  ///
  ///
  /// * [borderPaintColor] for specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  ///
  ///
  /// * [scrubberPaintColor] for specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  ///
  ///
  /// * [thumbnailQuality] for specifying the quality of each
  /// generated image thumbnail, to be displayed in the trimmer
  /// area.
  ///
  ///
  /// * [showDuration] for showing the start and the end point of the
  /// video on top of the trimmer area. By default it is set to `true`.
  ///
  ///
  /// * [durationTextStyle] is for providing a `TextStyle` to the
  /// duration text. By default it is set to
  /// `TextStyle(color: Colors.white)`
  ///
  ///
  /// * [onChangeStart] is a callback to the video start position.
  ///
  ///
  /// * [onChangeEnd] is a callback to the video end position.
  ///
  ///
  /// * [onChangePlaybackState] is a callback to the video playback
  /// state to know whether it is currently playing or paused.
  ///
  TrimEditor({
    @required this.viewerWidth,
    @required this.viewerHeight,
    this.fit = BoxFit.fitHeight,
    this.maxVideoLength = const Duration(milliseconds: 0),
    this.circleSize = 5.0,
    this.circleSizeOnDrag = 8.0,
    this.circlePaintColor = Colors.white,
    this.borderPaintColor = Colors.white,
    this.scrubberPaintColor = Colors.white,
    this.thumbnailQuality = 40,
    this.showDuration = true,
    this.durationTextStyle = const TextStyle(
      color: Colors.white,
    ),
    this.onChangeStart,
    this.onChangeEnd,
    this.onChangePlaybackState,
    @required this.videoPlayerController,
    @required this.videoFile,
    this.onHorizontalDragEnd,
    this.startTime,
    this.endTime,
  })  : assert(viewerWidth != null),
        assert(viewerHeight != null),
        assert(fit != null),
        assert(maxVideoLength != null),
        assert(circleSize != null),
        assert(circleSizeOnDrag != null),
        assert(circlePaintColor != null),
        assert(borderPaintColor != null),
        assert(scrubberPaintColor != null),
        assert(thumbnailQuality != null),
        assert(showDuration != null),
        assert(durationTextStyle != null);

  @override
  _TrimEditorState createState() => _TrimEditorState();
}

class _TrimEditorState extends State<TrimEditor> with TickerProviderStateMixin {
  File _videoFile;

  double _videoStartPos = 0.0;
  double _videoEndPos = 0.0;

  bool _canUpdateStart = true;
  bool _isLeftDrag = true;

  Offset _startPos = Offset(0, 0);
  Offset _endPos = Offset(0, 0);

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  int _videoDuration = 0;
  int _currentPosition = 0;

  double _thumbnailViewerW = 0.0;
  double _thumbnailViewerH = 0.0;

  int _numberOfThumbnails = 0;

  double _circleSize;

  double fraction;
  double maxLengthPixels;

  ThumbnailViewer thumbnailWidget;

  Animation<double> _scrubberAnimation;
  AnimationController _animationController;
  bool _isAnimationControllerDisposed = false;
  Tween<double> _linearTween;

  VideoPlayerController _videoPlayerController;

  Future<void> _initializeVideoController() async {
    if (_videoFile != null) {
      _videoPlayerController.addListener(() {
        final bool isPlaying = _videoPlayerController.value.isPlaying;
        //print("video playing: $isPlaying");
        if (isPlaying) {
          if (widget.onChangePlaybackState != null)
            widget.onChangePlaybackState(true);
          if (mounted)
            _currentPosition =
                _videoPlayerController.value.position.inMilliseconds;

          if (_currentPosition > _videoEndPos.toInt()) {
            // print(
            //     "video playing: ${_currentPosition > _videoEndPos.toInt()} stop condition ");

            if (widget.onChangePlaybackState != null)
              widget.onChangePlaybackState(false);
            _videoPlayerController.pause();
            _animationController.stop();
          } else {
            //print("video playing: animation duarion check ");
            if (_animationController != null &&
                _isAnimationControllerDisposed ==
                    false) if (!_animationController.isAnimating) {
              //print("video playing: animation stopped ");

              if (widget.onChangePlaybackState != null)
                widget.onChangePlaybackState(true);
              //print(_animationController.duration);
              _animationController.forward();
            }
          }
          setState(() {});
        } else {
          //print("video playing: check if initialized ");

          if (_videoPlayerController.value.initialized) {
            if (_animationController != null &&
                _isAnimationControllerDisposed == false) {
              //print("video playing: animation controller initialize");

              if ((_scrubberAnimation.value).toInt() == (_endPos.dx).toInt()) {
                _animationController.reset();
                // _animationController.forward();
              }
              _animationController.forward();
              videPlaybackControl(
                  startValue: _videoStartPos, endValue: _videoEndPos);

              // if (widget.onChangePlaybackState != null)
              // widget.onChangePlaybackState(false);
            }
          }
        }
      });

      _videoPlayerController.setVolume(1.0);
      _videoDuration = _videoPlayerController.value.duration.inMilliseconds;
      //print(_videoFile.path);
      _videoPlayerController.play();
      _videoEndPos = fraction != null
          ? _videoDuration.toDouble() * fraction
          : _videoDuration.toDouble();

      if (widget.onChangeEnd != null) widget.onChangeEnd(_videoEndPos);

      final ThumbnailViewer _thumbnailWidget = ThumbnailViewer(
        videoFile: _videoFile,
        videoDuration: _videoDuration,
        fit: widget.fit ?? BoxFit.fill,
        thumbnailHeight: _thumbnailViewerH,
        numberOfThumbnails: _numberOfThumbnails,
        quality: widget.thumbnailQuality,
      );
      thumbnailWidget = _thumbnailWidget;
    }
  }

  Future<bool> videPlaybackControl({
    @required double startValue,
    @required double endValue,
  }) async {
    if (_videoPlayerController.value.isPlaying) {
      await _videoPlayerController.pause();
      return false;
    } else {
      if (_videoPlayerController.value.position.inMilliseconds >=
          endValue.toInt()) {
        await _videoPlayerController
            .seekTo(Duration(milliseconds: startValue.toInt()));
        await _videoPlayerController.play();
        return true;
      } else {
        await _videoPlayerController.play();
        return true;
      }
    }
  }

  void _setVideoStartPosition(DragUpdateDetails details) async {
    if (!(_startPos.dx + details.delta.dx < 0) &&
        !(_startPos.dx + details.delta.dx > _thumbnailViewerW) &&
        !(_startPos.dx + details.delta.dx > _endPos.dx)) {
      if (maxLengthPixels != null) {
        if (!(_endPos.dx - _startPos.dx - details.delta.dx > maxLengthPixels)) {
          if (mounted)
            setState(() {
              if (!(_startPos.dx + details.delta.dx < 0))
                _startPos += details.delta;

              _startFraction = (_startPos.dx / _thumbnailViewerW);

              _videoStartPos = _videoDuration * _startFraction;
              if (widget.onChangeStart != null)
                widget.onChangeStart(_videoStartPos);
            });
          await _videoPlayerController.pause();
          await _videoPlayerController
              .seekTo(Duration(milliseconds: _videoStartPos.toInt()));
          _linearTween.begin = _startPos.dx;
          _animationController.duration =
              Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
          _animationController.reset();
        }
      } else {
        if (mounted)
          setState(() {
            if (!(_startPos.dx + details.delta.dx < 0))
              _startPos += details.delta;

            _startFraction = (_startPos.dx / _thumbnailViewerW);

            _videoStartPos = _videoDuration * _startFraction;
            if (widget.onChangeStart != null)
              widget.onChangeStart(_videoStartPos);
          });
        await _videoPlayerController.pause();
        await _videoPlayerController
            .seekTo(Duration(milliseconds: _videoStartPos.toInt()));
        _linearTween.begin = _startPos.dx;
        _animationController.duration =
            Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
        _animationController.reset();
      }
    }
  }

  void _setVideoEndPosition(DragUpdateDetails details) async {
    if (!(_endPos.dx + details.delta.dx > _thumbnailViewerW) &&
        !(_endPos.dx + details.delta.dx < 0) &&
        !(_endPos.dx + details.delta.dx < _startPos.dx)) {
      if (maxLengthPixels != null) {
        if (!(_endPos.dx - _startPos.dx + details.delta.dx > maxLengthPixels)) {
          if (mounted)
            setState(() {
              _endPos += details.delta;
              _endFraction = _endPos.dx / _thumbnailViewerW;

              _videoEndPos = _videoDuration * _endFraction;

              if (widget.onChangeEnd != null) widget.onChangeEnd(_videoEndPos);
            });
          await _videoPlayerController.pause();
          await _videoPlayerController
              .seekTo(Duration(milliseconds: _videoEndPos.toInt()));
          _linearTween.end = _endPos.dx;
          _animationController.duration =
              Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
          _animationController.reset();
        }
      } else {
        if (mounted)
          setState(() {
            _endPos += details.delta;
            _endFraction = _endPos.dx / _thumbnailViewerW;

            _videoEndPos = _videoDuration * _endFraction;

            if (widget.onChangeEnd != null) widget.onChangeEnd(_videoEndPos);
          });
        await _videoPlayerController.pause();
        await _videoPlayerController
            .seekTo(Duration(milliseconds: _videoEndPos.toInt()));
        _linearTween.end = _endPos.dx;
        _animationController.duration =
            Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
        _animationController.reset();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _videoStartPos = widget.startTime ?? _videoStartPos;
    _videoEndPos = widget.endTime ?? _videoEndPos;
    _circleSize = widget.circleSize;

    _videoPlayerController = widget.videoPlayerController;
    _videoFile = widget.videoFile;
    _thumbnailViewerH = widget.viewerHeight;

    _numberOfThumbnails = widget.viewerWidth ~/ _thumbnailViewerH;

    _thumbnailViewerW = _numberOfThumbnails * _thumbnailViewerH;

    Duration totalDuration = _videoPlayerController.value.duration;

    if (widget.maxVideoLength > Duration(milliseconds: 0) &&
        widget.maxVideoLength <= totalDuration) {
      if (widget.maxVideoLength <= totalDuration) {
        fraction =
            widget.maxVideoLength.inMilliseconds / totalDuration.inMilliseconds;

        maxLengthPixels = _thumbnailViewerW * fraction;
      }
    }

    _initializeVideoController();
    _endPos = Offset(
      maxLengthPixels != null ? maxLengthPixels : _thumbnailViewerW,
      _thumbnailViewerH,
    );

    // Defining the tween points
    _linearTween = Tween(begin: _startPos.dx, end: _endPos.dx);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt()),
    );

    _scrubberAnimation = _linearTween.animate(_animationController)
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.stop();
        }
      });
  }

  @override
  void dispose() {
    _isAnimationControllerDisposed = true;
    _animationController.dispose();

    // _animationController.dispose();

    _videoPlayerController.pause();
    if (widget.onChangePlaybackState != null)
      widget.onChangePlaybackState(false);
    if (_videoFile != null) {
      _videoPlayerController.setVolume(0.0);
      _videoPlayerController.pause();
      _videoPlayerController.dispose();
      if (widget.onChangePlaybackState != null)
        widget.onChangePlaybackState(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        //print("START");
        //print(details.localPosition);
        //print((_startPos.dx - details.localPosition.dx).abs());
        //print((_endPos.dx - details.localPosition.dx).abs());

        if (_endPos.dx >= _startPos.dx) {
          if ((_startPos.dx - details.localPosition.dx).abs() >
              (_endPos.dx - details.localPosition.dx).abs()) {
            if (mounted)
              setState(() {
                _canUpdateStart = false;
              });
          } else {
            if (mounted)
              setState(() {
                _canUpdateStart = true;
              });
          }
        } else {
          if (_startPos.dx > details.localPosition.dx) {
            _isLeftDrag = true;
          } else {
            _isLeftDrag = false;
          }
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (mounted)
          setState(() {
            _circleSize = widget.circleSize;
          });
        if (widget.onHorizontalDragEnd != null)
          widget.onHorizontalDragEnd(_videoStartPos, _videoEndPos);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _circleSize = widget.circleSizeOnDrag;

        print("=>>> ${details.localPosition} update");
        if (_endPos.dx >= _startPos.dx) {
          _isLeftDrag = false;
          if (_canUpdateStart && _startPos.dx + details.delta.dx > 0) {
            _isLeftDrag = false; // To prevent from scrolling over
            _setVideoStartPosition(details);
          } else if (!_canUpdateStart &&
              _endPos.dx + details.delta.dx < _thumbnailViewerW) {
            _isLeftDrag = true; // To prevent from scrolling over
            _setVideoEndPosition(details);
          }
        } else {
          if (_isLeftDrag && _startPos.dx + details.delta.dx > 0) {
            _setVideoStartPosition(details);
          } else if (!_isLeftDrag &&
              _endPos.dx + details.delta.dx < _thumbnailViewerW) {
            _setVideoEndPosition(details);
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.showDuration
              ? Container(
                  width: _thumbnailViewerW,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          Duration(milliseconds: _videoStartPos.toInt())
                              .toString()
                              .split('.')[0],
                          style: widget.durationTextStyle,
                        ),
                        Text(
                          Duration(milliseconds: _videoEndPos.toInt())
                              .toString()
                              .split('.')[0],
                          style: widget.durationTextStyle,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          CustomPaint(
            foregroundPainter: TrimEditorPainter(
              startPos: _startPos,
              endPos: _endPos,
              scrubberAnimationDx: _scrubberAnimation.value,
              circleSize: _circleSize,
              circlePaintColor: widget.circlePaintColor,
              borderPaintColor: widget.borderPaintColor,
              scrubberPaintColor: widget.scrubberPaintColor,
            ),
            child: Container(
              color: Colors.grey[900],
              height: _thumbnailViewerH,
              width: _thumbnailViewerW,
              child: thumbnailWidget == null ? Column() : thumbnailWidget,
            ),
          ),
        ],
      ),
    );
  }
}
