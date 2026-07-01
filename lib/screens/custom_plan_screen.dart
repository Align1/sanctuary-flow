import 'package:flutter/material.dart';
import 'package:rooted/models/reading_plan.dart';
import 'package:rooted/models/bible_books.dart';
import 'package:rooted/services/reading_plan_service.dart';
import 'package:rooted/utils/haptic_feedback.dart';
import 'package:intl/intl.dart';

enum ReadingOrder { traditional, historical, chronological }

class CustomPlanScreen extends StatefulWidget {
  const CustomPlanScreen({super.key});

  @override
  State<CustomPlanScreen> createState() => _CustomPlanScreenState();
}

class _CustomPlanScreenState extends State<CustomPlanScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _planNameController = TextEditingController();
  ReadingOrder _selectedOrder = ReadingOrder.traditional;
  String _startBook = 'Gen 1';
  String _endBook = 'Rev 22';
  final Set<int> _selectedDays = {
    0,
    1,
    2,
    3,
    4,
    5,
    6
  }; // All days selected by default
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 120));
  bool _otherOptionsExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleOtherOptions() {
    setState(() {
      _otherOptionsExpanded = !_otherOptionsExpanded;
      if (_otherOptionsExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    HapticFeedbackHelper.light();
  }

  void _selectReadingOrder(ReadingOrder order) {
    setState(() {
      _selectedOrder = order;
    });
    HapticFeedbackHelper.selection();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        }
      } else {
        _selectedDays.add(day);
      }
    });
    HapticFeedbackHelper.light();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF3B7A57),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 120));
        }
      });
      HapticFeedbackHelper.light();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF3B7A57),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      HapticFeedbackHelper.light();
    }
  }

  Future<void> _selectBook(bool isStart) async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookSelectorSheet(
        currentSelection: isStart ? _startBook : _endBook,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isStart) {
          _startBook = selected;
        } else {
          _endBook = selected;
        }
      });
      HapticFeedbackHelper.light();
    }
  }

  Future<void> _createPlan() async {
    // Calculate daily readings based on selected parameters
    final readings = _generateReadings();

    if (readings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please configure your reading plan')),
      );
      return;
    }

    // Use custom name or generate default
    final planName = _planNameController.text.trim().isEmpty
        ? 'Custom ${_getReadingOrderName()} Plan'
        : _planNameController.text.trim();

    final plan = ReadingPlanService.createCustomPlan(
      name: planName,
      description: 'Custom Bible reading plan from $_startBook to $_endBook',
      readings: readings,
    );

    await ReadingPlanService.savePlan(plan);

    if (mounted) {
      HapticFeedbackHelper.success();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reading plan created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  String _getReadingOrderName() {
    switch (_selectedOrder) {
      case ReadingOrder.traditional:
        return 'Traditional';
      case ReadingOrder.historical:
        return 'Historical';
      case ReadingOrder.chronological:
        return 'Chronological';
    }
  }

  // Calculate form completion progress (0.0 to 1.0)
  double get _formProgress {
    double progress = 0.0;

    // Each section worth 20%
    if (_planNameController.text.trim().isNotEmpty)
      progress += 0.2; // Plan name
    if (_startBook != 'Gen 1' || _endBook != 'Rev 22')
      progress += 0.2; // Books changed from default
    if (_selectedDays.isNotEmpty)
      progress += 0.2; // Reading days selected (always true by default)
    if (_startDate.difference(DateTime.now()).inDays >= 0)
      progress += 0.2; // Valid start date
    if (_endDate.isAfter(_startDate)) progress += 0.2; // Valid end date

    return progress.clamp(0.0, 1.0);
  }

  List<DailyReading> _generateReadings() {
    final readings = <DailyReading>[];

    // Get start and end book indices
    final startBookName = _startBook.split(' ')[0];
    final endBookName = _endBook.split(' ')[0];

    final startBookIndex =
        BibleBooks.allBooks.indexWhere((b) => b['name'] == startBookName);
    final endBookIndex =
        BibleBooks.allBooks.indexWhere((b) => b['name'] == endBookName);

    if (startBookIndex == -1 ||
        endBookIndex == -1 ||
        startBookIndex > endBookIndex) {
      return readings; // Invalid book selection
    }

    // Calculate total reading days in the date range based on selected weekdays
    int totalReadingDays = 0;
    DateTime currentDate = _startDate;
    while (currentDate.isBefore(_endDate) ||
        currentDate.isAtSameMomentAs(_endDate)) {
      final dayOfWeek = currentDate.weekday % 7; // Convert to 0-6 (Sun-Sat)
      if (_selectedDays.contains(dayOfWeek)) {
        totalReadingDays++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    if (totalReadingDays == 0) {
      return readings; // No reading days selected
    }

    // Get all books in range
    final booksInRange =
        BibleBooks.allBooks.sublist(startBookIndex, endBookIndex + 1);
    final totalChapters = booksInRange.fold<int>(
        0, (sum, book) => sum + (book['chapters'] as int));

    // Calculate chapters per reading day
    final chaptersPerDay = (totalChapters / totalReadingDays)
        .ceil()
        .clamp(1, 5); // Max 5 chapters per day

    // Generate daily readings
    int currentBookIndexInRange = 0;
    int currentChapterInBook = 1;
    int readingDayNumber = 1;

    currentDate = _startDate;
    while (currentDate.isBefore(_endDate) ||
        currentDate.isAtSameMomentAs(_endDate)) {
      final dayOfWeek = currentDate.weekday % 7;

      // Only create reading for selected days
      if (_selectedDays.contains(dayOfWeek)) {
        if (currentBookIndexInRange < booksInRange.length) {
          final currentBook = booksInRange[currentBookIndexInRange];
          final bookName = currentBook['name'] as String;
          final totalChaptersInBook = currentBook['chapters'] as int;

          // Determine chapter range for this reading
          int chaptersToRead = chaptersPerDay;
          int startChapter = currentChapterInBook;
          int endChapter = (currentChapterInBook + chaptersToRead - 1)
              .clamp(1, totalChaptersInBook);

          // Create reading
          final chapterRange = startChapter == endChapter
              ? '$startChapter'
              : '$startChapter-$endChapter';

          readings.add(DailyReading(
            day: readingDayNumber,
            bookName: bookName,
            chapters: chapterRange,
          ));

          readingDayNumber++;

          // Move to next chapters
          currentChapterInBook = endChapter + 1;

          // If we've finished this book, move to next
          if (currentChapterInBook > totalChaptersInBook) {
            currentBookIndexInRange++;
            currentChapterInBook = 1;
          }
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return readings;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1C1A16) : const Color(0xFF2C2821),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Read the Bible',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Text(
                      'Set start and end dates for your reading\nand create your personalized plan!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress Indicator
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0, right: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Form Progress',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(_formProgress * 100).toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _formProgress,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _formProgress >= 0.8
                                  ? Colors.green
                                  : _formProgress >= 0.5
                                      ? const Color(0xFFE8B44A)
                                      : Colors.white70,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content - Scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Create Now Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2821)
                            : const Color(0xFF3A3530),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create now:',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Plan Name Input
                          TextField(
                            controller: _planNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Plan Name (Optional)',
                              hintText: 'My Bible Reading Journey',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: const Color(0xFF4A4540),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Reading Order
                          Text(
                            'Reading order',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ReadingOrderSelector(
                            selectedOrder: _selectedOrder,
                            onSelectOrder: _selectReadingOrder,
                          ),
                          const SizedBox(height: 24),

                          // Start and End Reading
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start reading',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _DarkButton(
                                      text: _startBook,
                                      onTap: () => _selectBook(true),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End reading',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _DarkButton(
                                      text: _endBook,
                                      onTap: () => _selectBook(false),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Weekly Days
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Every week day',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _WeekdaySelector(
                            selectedDays: _selectedDays,
                            onToggleDay: _toggleDay,
                          ),
                          const SizedBox(height: 24),

                          // Start and End Date
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start date',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _DarkButton(
                                      text: DateFormat('MM/dd/yyyy')
                                          .format(_startDate),
                                      onTap: _selectStartDate,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End date',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _DarkButton(
                                      text: DateFormat('MM/dd/yyyy')
                                          .format(_endDate),
                                      onTap: _selectEndDate,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Other Options (Expandable)
                          InkWell(
                            onTap: _toggleOtherOptions,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  RotationTransition(
                                    turns: _rotationAnimation,
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Other options',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable Content
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _otherOptionsExpanded
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16.0, left: 32.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Additional options will appear here',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.white60,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Create Plan Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B7A57),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Create plan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reading Order Selector Widget
class _ReadingOrderSelector extends StatelessWidget {
  final ReadingOrder selectedOrder;
  final Function(ReadingOrder) onSelectOrder;

  const _ReadingOrderSelector({
    required this.selectedOrder,
    required this.onSelectOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _RadioOption(
              label: 'Traditional',
              isSelected: selectedOrder == ReadingOrder.traditional,
              onTap: () => onSelectOrder(ReadingOrder.traditional),
            ),
            const SizedBox(width: 16),
            _RadioOption(
              label: 'Historical',
              isSelected: selectedOrder == ReadingOrder.historical,
              onTap: () => onSelectOrder(ReadingOrder.historical),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _RadioOption(
              label: 'Chronological',
              isSelected: selectedOrder == ReadingOrder.chronological,
              onTap: () => onSelectOrder(ReadingOrder.chronological),
            ),
          ],
        ),
      ],
    );
  }
}

// Radio Option Widget
class _RadioOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFFE91E63) : Colors.white54,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Dark Button Widget
class _DarkButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _DarkButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF4A4540),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Weekday Selector Widget
class _WeekdaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final Function(int) onToggleDay;

  const _WeekdaySelector({
    required this.selectedDays,
    required this.onToggleDay,
  });

  static const List<String> dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = selectedDays.contains(index);
        return InkWell(
          onTap: () => onToggleDay(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFF5A5550)
                  : const Color(0xFF3A3530),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF7A7570) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                dayLabels[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Book Selector Bottom Sheet with Search and Testament Tabs
class _BookSelectorSheet extends StatefulWidget {
  final String currentSelection;

  const _BookSelectorSheet({
    required this.currentSelection,
  });

  @override
  State<_BookSelectorSheet> createState() => _BookSelectorSheetState();
}

class _BookSelectorSheetState extends State<_BookSelectorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredBooks(
      List<Map<String, dynamic>> books) {
    if (_searchQuery.isEmpty) return books;
    return books.where((book) {
      final name = (book['name'] as String).toLowerCase();
      final abbrev = (book['abbrev'] as String).toLowerCase();
      return name.contains(_searchQuery) || abbrev.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2821) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Book & Chapter',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF3A3530) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3A3530) : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Old Testament'),
                Tab(text: 'New Testament'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Book List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Old Testament
                _buildBookList(
                    _getFilteredBooks(BibleBooks.oldTestament), theme),
                // New Testament
                _buildBookList(
                    _getFilteredBooks(BibleBooks.newTestament), theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(List<Map<String, dynamic>> books, ThemeData theme) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final bookName = book['name'] as String;
        final abbrev = book['abbrev'] as String;
        final chapters = book['chapters'] as int;
        final isSelected = bookName == widget.currentSelection.split(' ').first;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                abbrev,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          title: Text(
            bookName,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            '$chapters ${chapters == 1 ? 'chapter' : 'chapters'}',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.pop(context, '$bookName 1');
          },
        );
      },
    );
  }
}
