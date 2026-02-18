import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:aivio/cubit/summary/summary_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aivio/presentation/widgets/summary/summary_app_bar.dart';
import 'package:aivio/presentation/widgets/summary/summary_loading_view.dart';
import 'package:aivio/presentation/widgets/summary/loading_overlay_widget.dart';
import 'package:aivio/presentation/widgets/summary/summary_content_widget.dart';
import 'package:aivio/presentation/widgets/summary/qa_section_widget.dart';
import 'package:aivio/presentation/widgets/summary/question_input_widget.dart';
import 'package:aivio/presentation/widgets/summary/share_options_dialog.dart';
import 'package:aivio/presentation/widgets/summary/summary_utils.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
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
        child: BlocBuilder<SummaryCubit, SummaryState>(
          builder: (context, state) {
            String title = 'Lecture Summary';
            bool showShare = false;
            String? content;

            if (state is SummaryLoaded) {
              if (state.summaryTitle != null) {
                title = state.summaryTitle!;
              }
              showShare = true;
              content = state.content;
            }

            return SummaryAppBar(
              title: title,
              showShareButton: showShare,
              onSharePressed: showShare && content != null
                  ? () => _showShareDialog(context, content!)
                  : null,
            );
          },
        ),
      ),
      body: BlocConsumer<SummaryCubit, SummaryState>(
        listener: (context, state) {
          if (state is SummaryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SummaryLoadingOverlay) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is SummaryLoading) {
            return SummaryLoadingView(message: state.message);
          }

          if (state is SummaryLoaded) {
            final isLoadingOverlay = state is SummaryLoadingOverlay;

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: 100,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SummaryContentWidget(content: state.content),

                            if (state.extractedText != null &&
                                state.settings != null) ...[
                              const SizedBox(height: 40),
                              QASectionWidget(
                                conversations: state.conversations,
                              ),
                            ],

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    if (state.extractedText != null && state.settings != null)
                      QuestionInputWidget(
                        controller: _questionController,
                        onSubmitted: () => _askQuestion(context),
                      ),
                  ],
                ),

                if (isLoadingOverlay)
                  LoadingOverlayWidget(message: state.loadingMessage),
              ],
            );
          }

          return const Center(child: Text('No summary available'));
        },
      ),
    );
  }

  void _showShareDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ShareOptionsDialog(
          onCopyText: () => _copyText(context, content),
          onShareImage: () => _shareAsImage(context),
        );
      },
    );
  }

  void _copyText(BuildContext context, String content) {
    final textToCopy = SummaryUtils.extractTextFromContent(content);
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Summary copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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

      final state = context.read<SummaryCubit>().state;
      String? contentString;
      if (state is SummaryLoaded) {
        contentString = state.content;
      }

      if (contentString == null) {
        throw Exception('No summary content to share');
      }

      final widget = Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SummaryContentWidget(content: contentString)],
        ),
      );

      final Uint8List image = await _generateImage(context, widget);

      final XFile file;
      if (kIsWeb) {
        file = XFile.fromData(
          image,
          mimeType: 'image/png',
          name: 'summary_${DateTime.now().millisecondsSinceEpoch}.png',
        );
      } else {
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/summary_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        file = XFile(imagePath);
      }

      await Share.shareXFiles([file], text: 'Check out this summary!');
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

  void _askQuestion(BuildContext context) {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    _questionController.clear();

    FocusScope.of(context).unfocus();

    context.read<SummaryCubit>().askFollowUpQuestion(question);
  }
}
