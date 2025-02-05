import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stream_chat_flutter/src/attachment/attachment_widget.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// {@macro giphy_attachment}
@Deprecated("Use 'StreamGiphyAttachment' instead")
typedef GiphyAttachment = StreamGiphyAttachment;

/// {@template giphy_attachment}
/// Widget for showing a GIF attachment
/// {@endtemplate}
class StreamGiphyAttachment extends StreamAttachmentWidget {
  /// Constructor for creating a [StreamGiphyAttachment] widget
  const StreamGiphyAttachment({
    super.key,
    required super.message,
    required super.attachment,
    super.size,
    this.onShowMessage,
    this.onReturnAction,
    this.onAttachmentTap,
    this.showSaveMediaButton = false,
  });

  /// Callback when show message is tapped
  final ShowMessageCallback? onShowMessage;

  /// Callback when attachment is returned to from other screens
  final ValueChanged<ReturnActionType>? onReturnAction;

  /// Callback when attachment is tapped
  final VoidCallback? onAttachmentTap;

  /// Display save media button
  final bool showSaveMediaButton;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        attachment.thumbUrl ?? attachment.imageUrl ?? attachment.assetUrl;
    if (imageUrl == null) {
      return const AttachmentError();
    }
    if (attachment.actions != null && attachment.actions!.isNotEmpty) {
      return _buildSendingAttachment(context, imageUrl);
    }
    return _buildSentAttachment(context, imageUrl);
  }

  Widget _buildSendingAttachment(BuildContext context, String imageUrl) {
    final streamChannel = StreamChannel.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          color: StreamChatTheme.of(context).colorTheme.barsBg,
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    StreamSvgIcon.giphyIcon(),
                    const SizedBox(width: 8),
                    Text(
                      context.translations.giphyLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    if (attachment.title != null)
                      Flexible(
                        child: Text(
                          attachment.title!,
                          style: TextStyle(
                            color: StreamChatTheme.of(context)
                                .colorTheme
                                .textHighEmphasis
                                .withOpacity(0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: GestureDetector(
                  onTap: () {
                    if (onAttachmentTap != null) {
                      onAttachmentTap?.call();
                    } else {
                      _onImageTap(context);
                    }
                  },
                  child: CachedNetworkImage(
                    height: size?.height,
                    width: size?.width,
                    placeholder: (_, __) => SizedBox(
                      width: size?.width,
                      height: size?.height,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    imageUrl: imageUrl,
                    errorWidget: (context, url, error) =>
                        AttachmentError(size: size),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                color: StreamChatTheme.of(context)
                    .colorTheme
                    .textHighEmphasis
                    .withOpacity(0.2),
                width: double.infinity,
                height: 0.5,
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          streamChannel.channel.sendAction(message, {
                            'image_action': 'cancel',
                          });
                        },
                        child: Text(
                          context.translations.cancelLabel
                              .toLowerCase()
                              .capitalize(),
                          style: StreamChatTheme.of(context)
                              .textTheme
                              .bodyBold
                              .copyWith(
                                color: StreamChatTheme.of(context)
                                    .colorTheme
                                    .textHighEmphasis
                                    .withOpacity(0.5),
                              ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 0.5,
                    color: StreamChatTheme.of(context)
                        .colorTheme
                        .textHighEmphasis
                        .withOpacity(0.2),
                    height: 50,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          streamChannel.channel.sendAction(message, {
                            'image_action': 'shuffle',
                          });
                        },
                        child: Text(
                          context.translations.shuffleLabel,
                          style: StreamChatTheme.of(context)
                              .textTheme
                              .bodyBold
                              .copyWith(
                                color: StreamChatTheme.of(context)
                                    .colorTheme
                                    .textHighEmphasis
                                    .withOpacity(0.5),
                              ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 0.5,
                    color: StreamChatTheme.of(context)
                        .colorTheme
                        .textHighEmphasis
                        .withOpacity(0.2),
                    height: 50,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          streamChannel.channel.sendAction(message, {
                            'image_action': 'send',
                          });
                        },
                        child: Text(
                          context.translations.sendLabel,
                          style: TextStyle(
                            color: StreamChatTheme.of(context)
                                .colorTheme
                                .accentPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: StreamVisibleFootnote(),
          ),
        ),
      ],
    );
  }

  void _onImageTap(BuildContext context) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          final channel = StreamChannel.of(context).channel;
          return StreamChannel(
            channel: channel,
            child: StreamFullScreenMedia(
              mediaAttachmentPackages: message.getAttachmentPackageList(),
              startIndex: message.attachments.indexOf(attachment),
              userName: message.user?.name,
              onShowMessage: onShowMessage,
              showShareButtonIcon: showSaveMediaButton,
              attachmentActionsModalBuilder: (
                context,
                attachment,
                defaultActionsModal,
              ) =>
                  defaultActionsModal.copyWith(showSave: showSaveMediaButton),
            ),
          );
        },
      ),
    );
    if (res != null) onReturnAction?.call(res);
  }

  Widget _buildSentAttachment(BuildContext context, String imageUrl) =>
      SizedBox(
        child: GestureDetector(
          onTap: () {
            if (onAttachmentTap != null) {
              onAttachmentTap?.call();
            } else {
              _onImageTap(context);
            }
          },
          child: Stack(
            children: [
              CachedNetworkImage(
                height: size?.height,
                width: size?.width,
                placeholder: (_, __) {
                  final image = Image.asset(
                    'images/placeholder.png',
                    fit: BoxFit.cover,
                    package: 'stream_chat_flutter',
                  );

                  final colorTheme = StreamChatTheme.of(context).colorTheme;
                  return Shimmer.fromColors(
                    baseColor: colorTheme.disabled,
                    highlightColor: colorTheme.inputBg,
                    child: image,
                  );
                },
                imageUrl: imageUrl,
                errorWidget: (context, url, error) =>
                    AttachmentError(size: size),
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Material(
                  color: StreamChatTheme.of(context)
                      .colorTheme
                      .textHighEmphasis
                      .withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        StreamSvgIcon.lightning(
                          color: StreamChatTheme.of(context).colorTheme.barsBg,
                          size: 16,
                        ),
                        Text(
                          context.translations.giphyLabel.toUpperCase(),
                          style: TextStyle(
                            color:
                                StreamChatTheme.of(context).colorTheme.barsBg,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
