import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aivio/core/constant/color.dart';
import 'package:aivio/cubit/assignment/assignment_cubit.dart';
import 'package:aivio/presentation/widgets/assignment/assignment_app_bar.dart';
import 'package:aivio/presentation/widgets/assignment/assignment_content_display.dart';
import 'package:aivio/presentation/widgets/assignment/assignment_loading_overlay.dart'
    as widgets;
import 'package:aivio/presentation/widgets/assignment/assignment_loading_view.dart';
import 'package:aivio/presentation/widgets/assignment/assignment_qa_section.dart';
import 'package:aivio/presentation/widgets/assignment/assignment_question_input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<AssignmentCubit, AssignmentState>(
          builder: (context, state) {
            String title = 'Assignment Help';
            bool showShare = false;
            String? content;

            if (state is AssignmentLoaded) {
              if (state.assignmentTitle != null) {
                title = state.assignmentTitle!;
              }
              showShare = true;
              content = state.content;
            } else if (state is AssignmentLoadingOverlay) {
              if (state.previousState.assignmentTitle != null) {
                title = state.previousState.assignmentTitle!;
              }
              showShare = true;
              content = state.previousState.content;
            }

            return AssignmentAppBar(
              title: title,
              showShare: showShare,
              onShare: () {
                if (content != null) {
                  _showShareDialog(context, content);
                }
              },
            );
          },
        ),
      ),
      body: BlocConsumer<AssignmentCubit, AssignmentState>(
        listener: (context, state) {
          if (state is AssignmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AssignmentLoadingOverlay) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is AssignmentLoading) {
            return AssignmentLoadingView(message: state.message);
          }

          if (state is AssignmentLoaded || state is AssignmentLoadingOverlay) {
            final loadedState = state is AssignmentLoaded
                ? state
                : (state as AssignmentLoadingOverlay).previousState;
            final bool isLoading = state is AssignmentLoadingOverlay;

            return Stack(
              children: [
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AssignmentContentDisplay(
                                content: loadedState.content,
                              ),
                              const SizedBox(height: 30),
                              const Divider(),
                              const SizedBox(height: 20),
                              AssignmentQASection(
                                conversations: loadedState.conversations,
                              ),

                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                      AssignmentQuestionInput(
                        controller: _questionController,
                        onSubmitted: () => _askQuestion(context),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  widgets.AssignmentLoadingOverlay(message: state.message),
              ],
            );
          }

          return const Center(child: Text('No assignment help available'));
        },
      ),
    );
  }

  void _askQuestion(BuildContext context) {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    _questionController.clear();

    FocusScope.of(context).unfocus();

    context.read<AssignmentCubit>().askFollowUpQuestion(question);
  }

  void _showShareDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Share Assignment Help',
            style: TextStyle(
              color: Appcolor.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy_rounded, color: Appcolor.primaryColor),
                title: const Text('Copy as Text'),
                subtitle: const Text('Copy assignment help to clipboard'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _copyText(context, content);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.image_rounded,
                  color: Appcolor.primaryColor,
                ),
                title: const Text('Share as Image'),
                subtitle: const Text('Generate and share as image'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _shareAsImage(context);
                },
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _copyText(BuildContext context, String content) {
    final textToCopy = _extractTextFromContent(content);
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Assignment help copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _extractTextFromContent(String content) {
    try {
      final jsonContent = json.decode(content);
      final StringBuffer buffer = StringBuffer();

      if (jsonContent['title'] != null) {
        buffer.writeln(jsonContent['title']);
        buffer.writeln();
      }

      if (jsonContent['content'] != null) {
        buffer.writeln(jsonContent['content']);
        buffer.writeln();
      }

      if (jsonContent['sections'] != null) {
        final sections = jsonContent['sections'] as List;
        for (var section in sections) {
          if (section['heading'] != null) {
            buffer.writeln('\n${section['heading']}');
          }
          if (section['content'] != null) {
            buffer.writeln(section['content']);
          }
        }
      }

      return buffer.toString();
    } catch (e) {
      return content;
    }
  }

  Future<void> _shareAsImage(BuildContext context) async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Generating image...'),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      final state = context.read<AssignmentCubit>().state;
      String? contentString;
      if (state is AssignmentLoaded) {
        contentString = state.content;
      } else if (state is AssignmentLoadingOverlay) {
        contentString = state.previousState.content;
      }

      if (contentString == null) {
        throw Exception('No assignment help content to share');
      }

      final widget = Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [AssignmentContentDisplay(content: contentString)],
        ),
      );

      final Uint8List image = await _generateImage(context, widget);

      final XFile file;
      if (kIsWeb) {
        file = XFile.fromData(
          image,
          mimeType: 'image/png',
          name: 'assignment_${DateTime.now().millisecondsSinceEpoch}.png',
        );
      } else {
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/assignment_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        file = XFile(imagePath);
      }

      await Share.shareXFiles([file], text: 'Check out this assignment help!');

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate image: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<Uint8List> _generateImage(BuildContext context, Widget widget) async {
    final double width = MediaQuery.of(context).size.width;
    final double height = 10000;

    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    final RenderView renderView = RenderView(
      view: View.of(context),
      child: RenderPositionedBox(
        alignment: Alignment.topCenter,
        child: boundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(Size(width, height)),
        devicePixelRatio: View.of(context).devicePixelRatio,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
          container: boundary,
          child: MediaQuery(
            data: MediaQuery.of(context),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Theme(
                data: Theme.of(context),
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width),
                    child: widget,
                  ),
                ),
              ),
            ),
          ),
        ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }
}
