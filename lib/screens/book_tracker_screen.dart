import 'package:flutter/material.dart';
import 'package:sanctuaryflow/models/book_reading.dart';
import 'package:sanctuaryflow/services/local_storage_service.dart';

class BookTrackerScreen extends StatefulWidget {
  const BookTrackerScreen({super.key});

  @override
  State<BookTrackerScreen> createState() => _BookTrackerScreenState();
}

class _BookTrackerScreenState extends State<BookTrackerScreen> {
  List<BookReading> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await LocalStorageService.getBookReadings();
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Tracker'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        title: 'Total Books',
                        value: '${_books.length}',
                        icon: Icons.library_books,
                      ),
                      _StatItem(
                        title: 'Reading',
                        value: '${_getReadingCount()}',
                        icon: Icons.menu_book,
                      ),
                      _StatItem(
                        title: 'Completed',
                        value: '${_getCompletedCount()}',
                        icon: Icons.check_circle,
                      ),
                    ],
                  ),
                ),

                // Books list with tabs
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          indicatorColor: theme.colorScheme.primary,
                          tabs: const [
                            Tab(text: 'Reading'),
                            Tab(text: 'Completed'),
                            Tab(text: 'All'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildBooksList('Reading'),
                              _buildBooksList('Completed'),
                              _buildBooksList('All'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBooksList(String filter) {
    List<BookReading> filteredBooks;
    
    switch (filter) {
      case 'Reading':
        filteredBooks = _books.where((book) => book.status == 'Reading').toList();
        break;
      case 'Completed':
        filteredBooks = _books.where((book) => book.status == 'Completed').toList();
        break;
      default:
        filteredBooks = _books;
    }

    if (filteredBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              filter == 'All' ? 'No books added yet' : 'No $filter books',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your Christian book reading',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        final book = filteredBooks[index];
        return _BookCard(
          book: book,
          onTap: () => _showBookDetails(book),
        );
      },
    );
  }

  int _getReadingCount() {
    return _books.where((book) => book.status == 'Reading').length;
  }

  int _getCompletedCount() {
    return _books.where((book) => book.status == 'Completed').length;
  }

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final pagesController = TextEditingController();
    final currentPageController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Book'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Mere Christianity',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  hintText: 'C.S. Lewis',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Pages',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: currentPageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current Page',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  authorController.text.isNotEmpty &&
                  pagesController.text.isNotEmpty) {
                final totalPages = int.tryParse(pagesController.text) ?? 0;
                final currentPage = int.tryParse(currentPageController.text) ?? 0;
                
                final book = BookReading(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  author: authorController.text,
                  totalPages: totalPages,
                  currentPage: currentPage,
                  startDate: DateTime.now(),
                  status: currentPage > 0 ? 'Reading' : 'Not Started',
                );

                await LocalStorageService.saveBookReading(book);
                await _loadBooks();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBookDetails(BookReading book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By ${book.author}'),
            const SizedBox(height: 8),
            Text('Progress: ${book.currentPage}/${book.totalPages} pages'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: book.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text('${book.progressPercentage.toStringAsFixed(1)}% complete'),
            const SizedBox(height: 8),
            Text('Status: ${book.status}'),
            if (book.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Rating: '),
                  for (int i = 1; i <= 5; i++)
                    Icon(
                      i <= book.rating! ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showUpdateProgressDialog(book);
            },
            child: const Text('Update Progress'),
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(BookReading book) {
    final pageController = TextEditingController(text: book.currentPage.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${book.title} (${book.totalPages} pages)'),
            const SizedBox(height: 16),
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Page',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newPage = int.tryParse(pageController.text) ?? book.currentPage;
              final updatedBook = BookReading(
                id: book.id,
                title: book.title,
                author: book.author,
                totalPages: book.totalPages,
                currentPage: newPage,
                startDate: book.startDate,
                completedDate: newPage >= book.totalPages ? DateTime.now() : null,
                status: newPage >= book.totalPages ? 'Completed' : 'Reading',
                notes: book.notes,
                rating: book.rating,
                tags: book.tags,
              );

              await LocalStorageService.saveBookReading(updatedBook);
              await _loadBooks();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8B5CF6)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        Text(
          title,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookReading book;
  final VoidCallback onTap;

  const _BookCard({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'by ${book.author}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(book.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      book.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(book.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: book.progressPercentage / 100,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(book.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${book.progressPercentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${book.currentPage}/${book.totalPages} pages',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Reading':
        return const Color(0xFF2563EB);
      case 'Completed':
        return const Color(0xFF10B981);
      case 'Paused':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}