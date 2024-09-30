import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class DragableFile extends StatefulWidget {
  const DragableFile({
    super.key,
    required this.name,
    required this.dragItemProvider,
  });

  final String name;
  final DragItemProvider dragItemProvider;
  @override
  State<DragableFile> createState() => _DragableFileState();
}

class _DragableFileState extends State<DragableFile> {
  bool _dragging = false;

  Future<DragItem?> provideDragItem(DragItemRequest request) async {
    final item = await widget.dragItemProvider(request);
    if (item != null) {
      void updateDraggingState() {
        setState(() {
          _dragging = request.session.dragging.value;
        });
      }

      request.session.dragging.addListener(updateDraggingState);
      updateDraggingState();
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return DragItemWidget(
      allowedOperations: () => [DropOperation.copy],
      canAddItemToExistingSession: true,
      dragItemProvider: provideDragItem,
      child: DraggableWidget(
        child: AnimatedOpacity(
          opacity: _dragging ? 0.5 : 1,
          duration: const Duration(milliseconds: 200),
          child: DottedBorder(
            radius:  const Radius.circular(8),
            borderType: BorderType.RRect,
            color: Colors.white,
            dashPattern: const [2, 4],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.file_present_sharp,
                  size: 60,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
