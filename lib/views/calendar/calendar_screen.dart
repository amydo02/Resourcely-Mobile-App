import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/task_model.dart';
import '../../models/canvas_assignment_model.dart';
import '../../utils/brand_colors.dart';
import '../../widgets/event_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _eventController = EventController();
  final _calendarController = CalendarController();
  bool _isLoading = true;
  bool _isLoadingCanvas = false;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _canvasFeedUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _canvasFeedUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Initialize calendar controller (loads saved Canvas feed)
    await _calendarController.initialize();
    
    // Load events
    await _eventController.loadEvents();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getItemsForDay(DateTime day) {
    final items = _calendarController.getItemsForDate(day);
    
    // Also add campus events for this day
    final dateStr = _formatDateForEvent(day);
    final campusEvents = _eventController.events.where((event) {
      return event.date == dateStr;
    }).toList();
    
    return [...items, ...campusEvents];
  }

  String _formatDateForEvent(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  

void _showAddTaskDialog() {
  _taskController.clear();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Add Task',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: TextField(
        controller: _taskController,
        decoration: InputDecoration(
          hintText: 'Task title',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Make this async and await the task addition
            await _calendarController.addTask(
              _taskController.text,
              dueDate: _selectedDay ?? DateTime.now(),
            );
            if (mounted) {
              setState(() {});
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: BrandColors.royalBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Add', style: TextStyle(color: BrandColors.lightSurface)),
        ),
      ],
    ),
  );
}
  Future<void> _linkCanvasFeed() async {
    final feedUrl = _canvasFeedUrlController.text.trim();
    
    if (feedUrl.isEmpty) {
      _showErrorSnackBar('Please enter your Canvas calendar feed URL');
      return;
    }

    setState(() => _isLoadingCanvas = true);

    try {
      final success = await _calendarController.linkCanvasFeed(feedUrl);


      
      setState(() => _isLoadingCanvas = false);
      
      if (success) {
        Navigator.pop(context);
        final assignmentCount = _calendarController.canvasAssignments.values
            .fold(0, (sum, list) => sum + list.length);
        _showSuccessSnackBar('Canvas linked! Found $assignmentCount assignments.');
        setState(() {});
      } else {
        _showErrorSnackBar('Invalid calendar feed URL. Please check and try again.');
      }
    } catch (e) {
      setState(() => _isLoadingCanvas = false);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showCanvasLinkDialog() {
    _canvasFeedUrlController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.link, color: BrandColors.royalBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _calendarController.isCanvasLinked ? 'Manage Canvas' : 'Link Canvas Calendar',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_calendarController.isCanvasLinked) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BrandColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BrandColors.successGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: BrandColors.successGreen, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Canvas Connected',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: BrandColors.textDark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your assignments are syncing automatically',
                              style: TextStyle(
                                fontSize: 12,
                                color: BrandColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _calendarController.unlinkCanvas();
                      setState(() {});
                      Navigator.pop(context);
                      _showSuccessSnackBar('Canvas calendar unlinked');
                    },
                    icon: const Icon(Icons.link_off),
                    label: const Text('Unlink Canvas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'How to get your Canvas Calendar Feed:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildInstructionStep('1', 'Open Canvas and go to Calendar'),
                const SizedBox(height: 8),
                _buildInstructionStep('2', 'Click on "Calendar Feed" at the bottom right'),
                const SizedBox(height: 8),
                _buildInstructionStep('3', 'Copy the calendar feed URL'),
                const SizedBox(height: 8),
                _buildInstructionStep('4', 'Paste it below'),
                const SizedBox(height: 16),
                TextField(
                  controller: _canvasFeedUrlController,
                  decoration: InputDecoration(
                    labelText: 'Canvas Calendar Feed URL',
                    hintText: 'https://canvas.sjsu.edu/feeds/...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.rss_feed),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrandColors.highlightBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrandColors.highlightBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline, size: 20, color: BrandColors.highlightBlue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your feed URL will be saved securely. You only need to enter it once!',
                          style: TextStyle(fontSize: 11, color: BrandColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (!_calendarController.isCanvasLinked)
            ElevatedButton(
              onPressed: _isLoadingCanvas ? null : _linkCanvasFeed,
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoadingCanvas
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Connect', style: TextStyle(color: BrandColors.lightSurface)),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: BrandColors.royalBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: BrandColors.royalBlue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: BrandColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BrandColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleEventTap(dynamic event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          event.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: BrandColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: BrandColors.slateGray),
                const SizedBox(width: 8),
                Text('Date: ${event.date}', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: BrandColors.slateGray),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location: ${event.location}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            if (event.description != null) ...[
              const SizedBox(height: 12),
              Text(
                event.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: BrandColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: BrandColors.slateGray)),
          ),
          ElevatedButton(
            onPressed: () {
              _eventController.rsvpForEvent(event.id);
              Navigator.pop(context);
              _showSuccessSnackBar('RSVP successful!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.royalBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('RSVP', style: TextStyle(color: BrandColors.lightSurface)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.lightSurface,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: BrandColors.royalBlue),
              )
            : Column(
                children: [
                  _buildHeader(),
                  _buildCalendar(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildItemsList()),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              if (_calendarController.isCanvasLinked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, size: 14, color: BrandColors.successGreen),
                      SizedBox(width: 4),
                      Text(
                        'Canvas Linked',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _showCanvasLinkDialog,
                icon: Icon(
                  _calendarController.isCanvasLinked ? Icons.sync : Icons.link_off,
                  color: _calendarController.isCanvasLinked
                      ? BrandColors.successGreen
                      : BrandColors.slateGray,
                ),
                tooltip: _calendarController.isCanvasLinked ? 'Manage Canvas' : 'Link Canvas',
              ),
              IconButton(
                onPressed: _showAddTaskDialog,
                icon: const Icon(Icons.add, color: BrandColors.royalBlue),
                tooltip: 'Add Task',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BrandColors.slateGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: _getItemsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: BrandColors.highlightBlue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: BrandColors.royalBlue,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: BrandColors.alertYellow,
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
      ),
    );
  }

  Widget _buildItemsList() {
    final items = _getItemsForDay(_selectedDay ?? DateTime.now());
    
    if (items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: BrandColors.slateGray.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BrandColors.slateGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 64,
                      color: BrandColors.slateGray.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tasks or events for this day',
                      style: TextStyle(
                        color: BrandColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.slateGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: BrandColors.slateGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                
                // Check if it's a TaskModel
                if (item is TaskModel) {
                  return _buildTaskCard(item);
                }
                // Check if it's a CanvasAssignmentModel
                else if (item is CanvasAssignmentModel) {
                  return _buildCanvasAssignmentCard(item);
                }
                // Otherwise it's a campus event
                else {
                  return GestureDetector(
                    onTap: () => _handleEventTap(item),
                    child: EventCard(
                      event: item,
                      onTap: () => _handleEventTap(item),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  

Widget _buildTaskCard(TaskModel task) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BrandColors.lightSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: task.completed
            ? BrandColors.successGreen.withOpacity(0.3)
            : BrandColors.slateGray.withOpacity(0.2),
      ),
    ),
    child: Row(
      children: [
        Checkbox(
          value: task.completed,
          onChanged: (_) async {
            await _calendarController.toggleTaskComplete(
              task.id,
              _selectedDay ?? DateTime.now(),
            );
            setState(() {});
          },
          activeColor: BrandColors.successGreen,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: task.completed ? TextDecoration.lineThrough : null,
                  color: task.completed
                      ? BrandColors.slateGray
                      : BrandColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.task_alt, size: 14, color: BrandColors.slateGray),
                  SizedBox(width: 4),
                  Text(
                    'Personal Task',
                    style: TextStyle(
                      fontSize: 12,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Replace the _buildCanvasAssignmentCard method in calendar_screen.dart with this:

Widget _buildCanvasAssignmentCard(CanvasAssignmentModel assignment) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BrandColors.highlightBlue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: assignment.completed
            ? BrandColors.successGreen.withOpacity(0.3)
            : BrandColors.highlightBlue.withOpacity(0.3),
      ),
    ),
    child: Row(
      children: [
        Checkbox(
          value: assignment.completed,
          onChanged: (_) async {
            await _calendarController.toggleCanvasAssignmentComplete(
              assignment.id,
              _selectedDay ?? DateTime.now(),
            );
            setState(() {});
          },
          activeColor: BrandColors.successGreen,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: assignment.completed
                      ? TextDecoration.lineThrough
                      : null,
                  color: assignment.completed
                      ? BrandColors.slateGray
                      : BrandColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.school, size: 14, color: BrandColors.highlightBlue),
                  const SizedBox(width: 4),
                  const Text(
                    'Canvas Assignment',
                    style: TextStyle(
                      fontSize: 12,
                      color: BrandColors.highlightBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (assignment.pointsPossible != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${assignment.pointsPossible} pts',
                      style: const TextStyle(
                        fontSize: 12,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}